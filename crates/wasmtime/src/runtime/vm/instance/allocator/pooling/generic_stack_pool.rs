#![cfg_attr(
    all(unix, not(miri), not(asan)),
    expect(dead_code, reason = "not used, but typechecked")
)]

use crate::PoolConcurrencyLimitError;
use crate::config::PoolingAllocationConfig;
use crate::prelude::*;
use alloc::sync::Arc;
use core::fmt;
use core::sync::atomic::{AtomicU64, Ordering};
use wasmtime_fiber::RuntimeFiberStackCreator;

/// A generic implementation of a stack pool.
///
/// This implementation technically doesn't actually pool anything at this time.
/// Originally this was the implementation for non-Unix (e.g. Windows and
/// MIRI), but nowadays this is also used for fuzzing. For more documentation
/// for why this is used on fuzzing see the `asan` module in the
/// `wasmtime-fiber` crate.
///
/// Currently the only purpose of `StackPool` is to limit the total number of
/// concurrent stacks while otherwise leveraging `wasmtime_fiber::FiberStack`
/// natively, or the embedder's [`RuntimeFiberStackCreator`] when
/// [`Config::with_host_stack`](crate::Config::with_host_stack) installed
/// one. A `no_std` embedder has no `mmap` behind `FiberStack::new`, only its
/// global allocator, so the creator is the one route by which it can place
/// fiber stacks in memory it commits on demand.
pub struct StackPool {
    stack_size: usize,
    stack_zeroing: bool,
    stack_creator: Option<Arc<dyn RuntimeFiberStackCreator>>,
    live_stacks: AtomicU64,
    stack_limit: u64,
}

impl fmt::Debug for StackPool {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("StackPool")
            .field("stack_size", &self.stack_size)
            .field("stack_zeroing", &self.stack_zeroing)
            .field("stack_creator", &self.stack_creator.is_some())
            .field("live_stacks", &self.live_stacks)
            .field("stack_limit", &self.stack_limit)
            .finish()
    }
}

impl StackPool {
    #[cfg(test)]
    pub fn enabled() -> bool {
        false
    }

    pub fn new(config: &PoolingAllocationConfig) -> Result<Self> {
        Ok(StackPool {
            stack_size: config.stack_size,
            stack_zeroing: config.async_stack_zeroing,
            stack_creator: None,
            live_stacks: AtomicU64::new(0),
            stack_limit: config.limits.total_stacks.into(),
        })
    }

    /// Route every stack this pool hands out through `stack_creator`.
    ///
    /// The pool keeps counting live stacks against its limit; only where the
    /// bytes come from changes.
    pub fn set_stack_creator(
        &mut self,
        stack_creator: Arc<dyn RuntimeFiberStackCreator>,
    ) -> Result<()> {
        self.stack_creator = Some(stack_creator);
        Ok(())
    }

    pub fn is_empty(&self) -> bool {
        self.live_stacks.load(Ordering::Acquire) == 0
    }

    pub fn allocate(&self) -> Result<wasmtime_fiber::FiberStack> {
        if self.stack_size == 0 {
            bail!("fiber stack allocation not supported")
        }

        let old_count = self.live_stacks.fetch_add(1, Ordering::AcqRel);
        if old_count >= self.stack_limit {
            self.live_stacks.fetch_sub(1, Ordering::AcqRel);
            return Err(PoolConcurrencyLimitError::new(
                usize::try_from(self.stack_limit).unwrap(),
                "fibers",
            )
            .into());
        }

        let stack = match &self.stack_creator {
            Some(stack_creator) => stack_creator
                .new_stack(self.stack_size, self.stack_zeroing)
                .and_then(wasmtime_fiber::FiberStack::from_custom),
            None => wasmtime_fiber::FiberStack::new(self.stack_size, self.stack_zeroing),
        };
        match stack {
            Ok(stack) => Ok(stack),
            Err(e) => {
                self.live_stacks.fetch_sub(1, Ordering::AcqRel);

                #[allow(
                    clippy::useless_conversion,
                    reason = "some `cfg`s have `wasmtime::Error` as the error type, others don't"
                )]
                let e = crate::Error::from(e);

                Err(e)
            }
        }
    }

    pub unsafe fn zero_stack(
        &self,
        _stack: &mut wasmtime_fiber::FiberStack,
        _decommit: impl FnMut(*mut u8, usize),
    ) -> usize {
        // No need to actually zero the stack, since the stack won't ever be
        // reused on non-unix systems.
        0
    }

    /// Safety: see the unix implementation.
    pub unsafe fn deallocate(&self, stack: wasmtime_fiber::FiberStack, _bytes_resident: usize) {
        self.live_stacks.fetch_sub(1, Ordering::AcqRel);
        // A no-op as we don't actually own the fiber stack on Windows.
        let _ = stack;
    }

    /// Safety: see the unix implementation.
    pub unsafe fn deallocate_many(
        &self,
        stacks: impl Iterator<Item = (wasmtime_fiber::FiberStack, usize)>,
    ) {
        for (stack, bytes_resident) in stacks {
            unsafe {
                self.deallocate(stack, bytes_resident);
            }
        }
    }

    pub fn unused_warm_slots(&self) -> u32 {
        0
    }

    pub fn unused_bytes_resident(&self) -> Option<usize> {
        None
    }
}

#[cfg(all(test, feature = "async", not(miri), not(asan)))]
mod tests {
    use super::*;
    use crate::config::InstanceLimits;
    use alloc::alloc::{Layout, alloc_zeroed, dealloc};
    use alloc::boxed::Box;
    use core::ops::Range;
    use core::sync::atomic::AtomicUsize;
    use wasmtime_fiber::RuntimeFiberStack;

    /// A page-aligned stack owned by the test, so the creator route can be
    /// observed without a second mapping primitive.
    struct OwnedStack {
        layout: Layout,
        base: *mut u8,
    }

    unsafe impl Send for OwnedStack {}
    unsafe impl Sync for OwnedStack {}

    impl Drop for OwnedStack {
        fn drop(&mut self) {
            unsafe { dealloc(self.base, self.layout) }
        }
    }

    unsafe impl RuntimeFiberStack for OwnedStack {
        fn top(&self) -> *mut u8 {
            unsafe { self.base.add(self.layout.size()) }
        }

        fn range(&self) -> Range<usize> {
            let base = self.base as usize;
            base..base + self.layout.size()
        }

        fn guard_range(&self) -> Range<*mut u8> {
            self.base..self.base
        }
    }

    struct RecordingCreator {
        page_size: usize,
        requests: AtomicUsize,
        last_size: AtomicUsize,
    }

    unsafe impl RuntimeFiberStackCreator for RecordingCreator {
        fn new_stack(&self, size: usize, _zeroed: bool) -> Result<Box<dyn RuntimeFiberStack>> {
            self.requests.fetch_add(1, Ordering::AcqRel);
            self.last_size.store(size, Ordering::Release);
            let layout = Layout::from_size_align(size, self.page_size).unwrap();
            let base = unsafe { alloc_zeroed(layout) };
            assert!(!base.is_null());
            Ok(Box::new(OwnedStack { layout, base }))
        }
    }

    fn config(total_stacks: u32, stack_size: usize) -> PoolingAllocationConfig {
        PoolingAllocationConfig {
            limits: InstanceLimits {
                total_stacks,
                ..Default::default()
            },
            stack_size,
            async_stack_zeroing: false,
            ..PoolingAllocationConfig::default()
        }
    }

    #[test]
    fn allocate_routes_through_the_stack_creator() -> Result<()> {
        let page_size = crate::runtime::vm::host_page_size();
        let creator = Arc::new(RecordingCreator {
            page_size,
            requests: AtomicUsize::new(0),
            last_size: AtomicUsize::new(0),
        });
        let mut pool = StackPool::new(&config(2, 4 * page_size))?;
        pool.set_stack_creator(creator.clone())?;

        let first = pool.allocate()?;
        let second = pool.allocate()?;
        assert_eq!(creator.requests.load(Ordering::Acquire), 2);
        assert_eq!(creator.last_size.load(Ordering::Acquire), 4 * page_size);
        assert!(first.top().is_some());
        assert_ne!(first.top(), second.top());

        assert!(
            pool.allocate().is_err(),
            "the pool still enforces its limit"
        );
        assert_eq!(
            creator.requests.load(Ordering::Acquire),
            2,
            "a refused allocation never reaches the creator"
        );

        unsafe {
            pool.deallocate(first, 0);
            pool.deallocate(second, 0);
        }
        assert!(pool.is_empty());
        Ok(())
    }
}

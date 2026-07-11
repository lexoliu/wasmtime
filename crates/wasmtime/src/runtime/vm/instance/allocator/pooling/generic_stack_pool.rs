#![cfg_attr(
    all(unix, not(miri), not(asan)),
    expect(dead_code, reason = "not used, but typechecked")
)]

use crate::PoolConcurrencyLimitError;
use crate::config::PoolingAllocationConfig;
use crate::prelude::*;
#[cfg(not(feature = "std"))]
use crate::sync::Mutex;
use core::fmt;
use core::sync::atomic::{AtomicU64, Ordering};
#[cfg(feature = "std")]
use std::sync::Mutex;

/// A generic implementation of a stack pool.
///
/// This implementation is used by targets that cannot reserve one large
/// Unix-style stack mapping. It still keeps a bounded warm stack list so async
/// core-module startup does not allocate and free a large fiber stack on every
/// store drop.
pub struct StackPool {
    stack_size: usize,
    stack_zeroing: bool,
    live_stacks: AtomicU64,
    stack_limit: u64,
    max_unused_warm_slots: usize,
    unused_stacks: Mutex<Vec<wasmtime_fiber::FiberStack>>,
}

impl fmt::Debug for StackPool {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("StackPool")
            .field("stack_size", &self.stack_size)
            .field("stack_zeroing", &self.stack_zeroing)
            .field("live_stacks", &self.live_stacks)
            .field("stack_limit", &self.stack_limit)
            .field("max_unused_warm_slots", &self.max_unused_warm_slots)
            .field("unused_warm_slots", &self.unused_warm_slots())
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
            live_stacks: AtomicU64::new(0),
            stack_limit: config.limits.total_stacks.into(),
            max_unused_warm_slots: usize::try_from(config.max_unused_warm_slots).unwrap(),
            unused_stacks: Mutex::new(Vec::new()),
        })
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

        if let Some(stack) = self
            .unused_stacks
            .lock()
            .expect("generic stack pool mutex must not fail")
            .pop()
        {
            return Ok(stack);
        }

        match wasmtime_fiber::FiberStack::new(self.stack_size, self.stack_zeroing) {
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
        let mut unused_stacks = self
            .unused_stacks
            .lock()
            .expect("generic stack pool mutex must not fail");
        if unused_stacks.len() < self.max_unused_warm_slots && !self.stack_zeroing {
            unused_stacks.push(stack);
        }
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
        self.unused_stacks
            .lock()
            .expect("generic stack pool mutex must not fail")
            .len()
            .try_into()
            .unwrap_or(u32::MAX)
    }

    pub fn unused_bytes_resident(&self) -> Option<usize> {
        None
    }
}

// This pool is the live implementation only on non-unix targets; a test
// exercising it on unix would defeat the module's `expect(dead_code)`.
#[cfg(all(test, not(unix), not(miri), not(asan)))]
mod tests {
    use super::*;
    use crate::runtime::vm::InstanceLimits;

    #[test]
    fn reuses_warm_stack_slots() {
        let config = PoolingAllocationConfig {
            max_unused_warm_slots: 1,
            stack_size: 64 * 1024,
            async_stack_zeroing: false,
            limits: InstanceLimits {
                total_stacks: 4,
                ..Default::default()
            },
            ..PoolingAllocationConfig::default()
        };

        let pool = StackPool::new(&config).unwrap();
        let first = pool.allocate().unwrap();
        let first_top = first.top();
        unsafe {
            pool.deallocate(first, 0);
        }

        assert_eq!(pool.unused_warm_slots(), 1);
        let second = pool.allocate().unwrap();
        assert_eq!(second.top(), first_top);
        unsafe {
            pool.deallocate(second, 0);
        }
    }
}

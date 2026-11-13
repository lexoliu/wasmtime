//! Guest-memory residency for the copies the event loop makes on the host's
//! behalf.
//!
//! Much of what moves between a guest's linear memory and the host through a
//! `stream` or `future` is copied by Wasmtime itself, from the store's event
//! loop: a flat payload a host producer delivers is lowered straight into the
//! guest's read buffer, a host consumer lifts flat items out of the guest's
//! write buffer, and the `stream<u8>` direct views hand the guest's buffer to
//! the producer or consumer to copy themselves. The event loop runs on
//! whatever stack polls the store, never on a guest fiber.
//!
//! An embedder whose linear memory can lose pages (swapped out, or populated
//! on demand from somewhere else) resolves a touch of a missing page by
//! blocking the fiber that touched it, through
//! [`block_on_current_fiber`](crate::block_on_current_fiber). A copy the event
//! loop makes has no fiber to block, so it must never touch a missing page.
//! [`GuestMemoryResidency`] is how the embedder keeps that from happening:
//! before each such copy, in the same poll as the copy, Wasmtime names the
//! bytes the copy is about to touch, and if the embedder says they are not all
//! present the copy waits until they have been brought in and checks again.
//!
//! A copy whose extent is not known before it starts — lifting a payload that
//! holds strings or lists, which follows guest pointers as it goes — does not
//! run on the event loop at all when a residency hook is registered: the host
//! consumer that performs it is polled on a worker fiber, where a missing page
//! blocks that fiber like any access the guest makes itself. Lowering such a
//! payload already runs there, because it may call the guest's `realloc`.

use crate::prelude::*;
use crate::store::StoreOpaque;
use crate::{Error, Result};
use core::future::Future;
use core::pin::Pin;
use core::ptr::NonNull;
use core::task::{Context, Poll, ready};
use futures::FutureExt as _;

/// An embedder's say over when the event loop may copy guest bytes.
///
/// Register one on a store with
/// [`Store::set_guest_memory_residency`](crate::Store::set_guest_memory_residency).
/// Without one, the event loop copies guest bytes whenever an operation is
/// ready, which is correct for every embedder whose linear memories are always
/// present.
///
/// # Contract
///
/// Wasmtime calls [`Self::wait_until_resident`] in the poll that makes the
/// copy, before the copy, with nothing awaited in between. An answer of `None`
/// means every byte named may be touched until that poll returns, and the copy
/// is made at once. An answer of `Some(wait)` means some byte is missing: the
/// copy is not made, the operation awaits `wait` instead, and once `wait`
/// completes the bytes are named again from scratch, because they may have
/// gone missing again in the meantime. How the embedder makes `None` hold for
/// the rest of the poll (for instance, by never evicting a page of a store
/// while that store is being polled) is its own business.
///
/// An error from `wait` fails the operation the way a failed copy does: the
/// guest on the other end of the stream or future traps.
///
/// # Concurrency
///
/// The hook is owned by the store and called with the store exclusively
/// borrowed, so it is never called concurrently with itself. The `wait`
/// futures it hands out are independent of it and of each other: several
/// operations may each be awaiting one at the same time.
pub trait GuestMemoryResidency: Send + 'static {
    /// Why a missing byte could not be brought back.
    type Error: core::error::Error + Send + Sync + 'static;

    /// Completes once the bytes it was handed out for are worth naming again.
    type Wait: Future<Output = Result<(), Self::Error>> + Send + 'static;

    /// Called with the host address range of the guest bytes a copy is about
    /// to read or write. The range is never empty and always lies inside one
    /// of the store's linear memories.
    ///
    /// Returns `None` when every byte of `bytes` may be touched now, and
    /// otherwise a future that brings at least one missing byte back.
    fn wait_until_resident(&mut self, bytes: NonNull<[u8]>) -> Option<Self::Wait>;
}

/// A residency wait as the event loop holds it: whatever the embedder's
/// [`GuestMemoryResidency::Wait`] is, with its error converted.
type ResidencyWait = Pin<Box<dyn Future<Output = Result<()>> + Send>>;

/// [`GuestMemoryResidency`] with its associated types erased, which is what a
/// store, monomorphic in the hook, can hold.
pub(crate) trait ErasedGuestMemoryResidency: Send {
    fn wait_until_resident(&mut self, bytes: NonNull<[u8]>) -> Option<ResidencyWait>;
}

impl<R: GuestMemoryResidency> ErasedGuestMemoryResidency for R {
    fn wait_until_resident(&mut self, bytes: NonNull<[u8]>) -> Option<ResidencyWait> {
        let wait = GuestMemoryResidency::wait_until_resident(self, bytes)?;
        Some(Box::pin(wait.map(|outcome| outcome.map_err(Error::new))))
    }
}

/// The residency wait one copy site has in progress, kept across the polls of
/// the operation that makes the copy.
#[derive(Default)]
pub(crate) struct ResidencyCheck {
    wait: Option<ResidencyWait>,
}

impl ResidencyCheck {
    /// Polls until the bytes `span` names may be copied in this poll.
    ///
    /// `span` names the bytes the copy will touch, or `None` when it touches
    /// none (an empty transfer, or one whose bounds check is about to fail the
    /// copy anyway). It is only called when the store has a residency hook, so
    /// a store without one pays a single branch per copy.
    ///
    /// `Ready(Ok(()))` means the copy may be made now, before this poll
    /// returns; `Pending` means it must not be, and the operation is woken
    /// once it is worth checking again.
    pub(crate) fn poll(
        &mut self,
        cx: &mut Context<'_>,
        store: &mut StoreOpaque,
        span: impl FnOnce(&mut StoreOpaque) -> Result<Option<NonNull<[u8]>>>,
    ) -> Poll<Result<()>> {
        if store.component_data().guest_memory_residency.is_none() {
            return Poll::Ready(Ok(()));
        }
        let Some(bytes) = span(store)? else {
            return Poll::Ready(Ok(()));
        };
        let Some(residency) = store.component_data_mut().guest_memory_residency.as_mut() else {
            return Poll::Ready(Err(crate::format_err!(
                "wasmtime bug: the residency hook disappeared while a copy was being checked"
            )));
        };
        let residency = residency.get_mut();
        loop {
            if let Some(wait) = &mut self.wait {
                let outcome = ready!(wait.as_mut().poll(cx));
                self.wait = None;
                outcome?;
            }
            match residency.wait_until_resident(bytes) {
                None => return Poll::Ready(Ok(())),
                Some(wait) => self.wait = Some(wait),
            }
        }
    }
}

/// The host address range of the `len` bytes at `address` in `memory`, or
/// `None` when that is empty or not inside `memory`. A copy that is out of
/// bounds is refused by the copy's own bounds check, with its own error.
pub(crate) fn guest_span(memory: &[u8], address: usize, len: usize) -> Option<NonNull<[u8]>> {
    if len == 0 {
        return None;
    }
    memory.get(address..)?.get(..len).map(NonNull::from)
}

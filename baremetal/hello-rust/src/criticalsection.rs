use core::sync::atomic::{AtomicU32, Ordering};
use critical_section::RawRestoreState;

use super::mpfs::hart_id;

struct MPFSCriticalSection;
critical_section::set_impl!(MPFSCriticalSection);

const LOCK_UNOWNED: u32 = 0;
const LOCK_ALREADY_OWNED: u32 = u32::MAX;

// Stores which hart (core) owns the lock: 0 = unowned, 1-4 = hart ID
static LOCK_OWNER: AtomicU32 = AtomicU32::new(LOCK_UNOWNED);

unsafe impl critical_section::Impl for MPFSCriticalSection {
    unsafe fn acquire() -> RawRestoreState {
        let hart_id: u32 = hart_id() + 1; // Convert to 1-based for our lock system

        // Check if we already own the lock
        if LOCK_OWNER.load(Ordering::Acquire) == hart_id {
            return LOCK_ALREADY_OWNED;
        }

        // Read current mstatus (we'll need to restore it later)
        let mut mstatus: u32;
        core::arch::asm!(
            "csrr {}, mstatus",
            out(reg) mstatus
        );

        loop {
            // Disable interrupts while we try to acquire the lock
            core::arch::asm!(
                "csrci mstatus, 0x8", // Clear MIE bit
                options(nomem, nostack)
            );

            // Try to acquire the lock
            match LOCK_OWNER.compare_exchange(
                LOCK_UNOWNED,
                hart_id,
                Ordering::AcqRel,
                Ordering::Acquire,
            ) {
                Ok(_) => break, // We got the lock
                Err(_) => {
                    // We didn't get the lock, restore interrupts if they were enabled
                    if (mstatus & 0x8) != 0 {
                        core::arch::asm!(
                            "csrsi mstatus, 0x8", // Set MIE bit
                            options(nomem, nostack)
                        );
                    }
                }
            }
        }

        mstatus
    }

    unsafe fn release(token: RawRestoreState) {
        if token != LOCK_ALREADY_OWNED {
            // Release the lock
            LOCK_OWNER.store(LOCK_UNOWNED, Ordering::Release);

            // Restore previous interrupt state
            core::arch::asm!(
                "csrw mstatus, {0}",
                in(reg) token,
                options(nomem, nostack)
            );
        }
    }
}

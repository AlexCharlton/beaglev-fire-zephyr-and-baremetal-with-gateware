mod bindings;
pub use bindings::*;

mod clint;
pub use clint::*;

mod encoding;
pub use encoding::*;

mod timer;
pub use timer::*;

mod uart;
pub use uart::*;

#[inline]
pub fn hart_id() -> usize {
    let mut hart_id: usize;
    unsafe {
        core::arch::asm!("csrr {}, mhartid", out(reg) hart_id);
    }
    hart_id
}

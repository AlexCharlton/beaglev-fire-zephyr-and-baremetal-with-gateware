pub fn hart_id() -> u32 {
    let mut hart_id: u32;
    unsafe {
        core::arch::asm!("csrr {}, mhartid", out(reg) hart_id);
    }
    hart_id
}

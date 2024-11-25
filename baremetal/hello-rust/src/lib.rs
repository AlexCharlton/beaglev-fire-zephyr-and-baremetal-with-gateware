#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn u54_1() {
    unsafe {
        // Rest of hardware initialization
        clear_soft_interrupt_rs();
        PLIC_init_rs();
        enable_irq_rs();
        mss_config_clk_rst(0, 1, 0);
        // Initialize UART first, before any printing
        uart_init_rs();
        let hart_id: u32;
        core::arch::asm!("csrr {}, mhartid", out(reg) hart_id);

        // Main message
        uart_puts_rs(b"\r\n\0".as_ptr());
        uart_puts_rs(b"Hello World from rust from hart \0".as_ptr());

        // Create a static buffer for the number
        static mut NUM_BUF: [u8; 32] = [0; 32]; // Initialize with zeros

        // Convert number to string
        let mut buf = itoa::Buffer::new();
        let num_str = buf.format(hart_id);

        // Copy to our null-terminated buffer
        for (i, &byte) in num_str.as_bytes().iter().enumerate() {
            NUM_BUF[i] = byte;
        }
        // Null terminator is already there since we initialized with zeros

        uart_puts_rs(NUM_BUF.as_ptr());
        uart_puts_rs(b"!\r\n\0".as_ptr());
    }
}

// External C functions we need to call
extern "C" {
    fn clear_soft_interrupt_rs();
    fn PLIC_init_rs();
    fn enable_irq_rs();
    fn mss_config_clk_rst(periph: u32, hart: u8, enable: u32);
    fn uart_init_rs();
    fn uart_puts_rs(s: *const u8);
}

#[inline]
unsafe fn set_csr_rs(reg: u32, bit: u32) {
    match reg {
        0x304 => core::arch::asm!("csrs mie, {}", in(reg) bit),
        // Add other CSR cases as needed
        x => panic!("Unsupported CSR register: {}", x),
    }
}

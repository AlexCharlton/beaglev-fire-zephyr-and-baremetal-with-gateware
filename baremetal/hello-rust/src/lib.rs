#![no_std]
#![no_main]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {}
}

#[no_mangle]
pub extern "C" fn u54_1() {
    // We'll implement this function to match your C code
    unsafe {
        // Basic hart setup
        clear_soft_interrupt_rs();
        //set_csr_rs(0x304, 0x8); // mie, MIP_MSIP

        // Initialize PLIC and enable interrupts
        PLIC_init_rs();
        enable_irq_rs();

        // Configure clocks for UART0
        mss_config_clk_rst(0, 1, 0); // MSS_PERIPH_MMUART0, MPFS_HAL_FIRST_HART, PERIPHERAL_ON

        // Initialize UART0
        uart_init_rs();
        uart_puts_rs("\r\n".as_ptr());
        uart_puts_rs("Hello World from rust!\r\n".as_ptr());
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

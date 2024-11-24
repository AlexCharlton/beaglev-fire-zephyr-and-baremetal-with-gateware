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
        clear_soft_interrupt();
        set_csr(0x304, 0x8); // mie, MIP_MSIP

        // Initialize PLIC and enable interrupts
        PLIC_init();
        enable_irq();

        // Configure clocks for UART0
        mss_config_clk_rst(0, 0, 1); // MSS_PERIPH_MMUART0, MPFS_HAL_FIRST_HART, PERIPHERAL_ON

        // Initialize UART0
        uart_init();
        uart_puts("\r\n".as_ptr());
        uart_puts("Hello World from rust!\r\n".as_ptr());
    }
}

// External C functions we need to call
extern "C" {
    fn clear_soft_interrupt();
    fn PLIC_init();
    fn enable_irq();
    fn mss_config_clk_rst(periph: u32, hart: u8, enable: u32);
    fn uart_init();
    fn uart_puts(s: *const u8);
}

#[inline]
unsafe fn set_csr(reg: u32, bit: u32) {
    match reg {
        0x304 => core::arch::asm!("csrs mie, {}", in(reg) bit),
        // Add other CSR cases as needed
        _ => panic!("Unsupported CSR register"),
    }
}

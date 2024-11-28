#![no_std]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embedded_alloc::LlffHeap as Heap;

pub mod sys;
use sys::hart_id;

mod critical_section_impl;

critical_section::set_impl!(critical_section_impl::MPFSCriticalSection);

#[global_allocator]
static HEAP: Heap = Heap::empty();

unsafe fn init_heap() {
    use core::mem::MaybeUninit;
    const HEAP_SIZE: usize = 1024;
    static mut HEAP_MEM: [MaybeUninit<u8>; HEAP_SIZE] = [MaybeUninit::uninit(); HEAP_SIZE];
    HEAP.init(addr_of_mut!(HEAP_MEM) as usize, HEAP_SIZE)
}

#[panic_handler]
fn panic(panic: &PanicInfo<'_>) -> ! {
    // Print panic message if available
    if let Some(location) = panic.location() {
        let msg = format!(
            "\nPANIC at {}:{} - {}\n\0",
            location.file(),
            location.line(),
            panic.message()
        );
        uart_puts(msg.as_ptr());
    }

    loop {
        // Optional: Could add some hardware-specific error indication here
        // like blinking an LED or triggering a watchdog reset
    }
}

#[no_mangle]
pub extern "C" fn u54_1() {
    unsafe {
        // Rest of hardware initialization
        sys::clear_soft_interrupt();
        core::arch::asm!("csrs mie, {}", const sys::MIP_MSIP, options(nomem, nostack));

        sys::PLIC_init();
        sys::__enable_irq();
        sys::mss_config_clk_rst(
            sys::mss_peripherals__MSS_PERIPH_MMUART0,
            sys::MPFS_HAL_FIRST_HART as u8,
            sys::PERIPH_RESET_STATE__PERIPHERAL_ON,
        );
        sys::MSS_UART_init(
            addr_of_mut!(sys::g_mss_uart0_lo),
            sys::MSS_UART_115200_BAUD,
            sys::MSS_UART_DATA_8_BITS | sys::MSS_UART_NO_PARITY | sys::MSS_UART_ONE_STOP_BIT,
        );

        init_heap();

        uart_puts(b"\n\0".as_ptr());
        let msg = format!("Hello World from Rust from hart {}!\n\0", hart_id());
        uart_puts(msg.as_ptr());

        let mut xs = Vec::new();
        xs.push(1);

        let msg = format!("Got value {} from the heap!\n\0", xs.pop().unwrap());
        uart_puts(msg.as_ptr());

        panic!("This is a test panic!");
    }
}

fn uart_puts(s: *const u8) {
    unsafe {
        sys::MSS_UART_polled_tx_string(addr_of_mut!(sys::g_mss_uart0_lo), s);
    }
}

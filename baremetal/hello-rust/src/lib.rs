#![no_std]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embedded_alloc::LlffHeap as Heap;

pub mod sys;
pub use sys::*;

mod mpfs;
use mpfs::*;
mod criticalsection;

#[global_allocator]
static HEAP: Heap = Heap::empty();

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
        sys::MSS_UART_init(
            addr_of_mut!(sys::g_mss_uart0_lo),
            sys::MSS_UART_115200_BAUD,
            sys::MSS_UART_DATA_8_BITS | sys::MSS_UART_NO_PARITY | sys::MSS_UART_ONE_STOP_BIT,
        );

        {
            use core::mem::MaybeUninit;
            const HEAP_SIZE: usize = 1024;
            static mut HEAP_MEM: [MaybeUninit<u8>; HEAP_SIZE] = [MaybeUninit::uninit(); HEAP_SIZE];
            HEAP.init(addr_of_mut!(HEAP_MEM) as usize, HEAP_SIZE)
        }

        uart_puts_rs(b"\n\0".as_ptr());
        let msg = format!("Hello World from Rust from hart {}!\n\0", hart_id());
        uart_puts_rs(msg.as_ptr());

        let mut xs = Vec::new();
        xs.push(1);

        let msg = format!("Got value {} from the heap!\n\0", xs.pop().unwrap());
        uart_puts_rs(msg.as_ptr());
    }
}

// External C functions we need to call
extern "C" {
    fn clear_soft_interrupt_rs();
    fn PLIC_init_rs();
    fn enable_irq_rs();
    fn mss_config_clk_rst(periph: u32, hart: u8, enable: u32);
    fn uart_puts_rs(s: *const u8);
}

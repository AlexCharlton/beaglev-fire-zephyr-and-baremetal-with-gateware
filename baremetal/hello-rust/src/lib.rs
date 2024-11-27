#![no_std]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embedded_alloc::LlffHeap as Heap;

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
        uart_init_rs();

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
    fn uart_init_rs();
    fn uart_puts_rs(s: *const u8);
}

#[inline]
unsafe fn _set_csr_rs(reg: u32, bit: u32) {
    match reg {
        0x304 => core::arch::asm!("csrs mie, {}", in(reg) bit),
        // Add other CSR cases as needed
        x => panic!("Unsupported CSR register: {}", x),
    }
}

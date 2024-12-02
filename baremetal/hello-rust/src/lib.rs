#![no_std]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embedded_alloc::LlffHeap as Heap;

pub mod sys;
use sys::hart_id;

pub mod critical_section_impl;
pub mod time_driver;

critical_section::set_impl!(critical_section_impl::MPFSCriticalSection);

#[global_allocator]
static HEAP: Heap = Heap::empty();

unsafe fn init_heap() {
    HEAP.init(
        sys::last_linked_address(),
        sys::last_address() - sys::last_linked_address(),
    )
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
        // TODO: Do something useful? Reset?
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
        time_driver::init();
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
        let now = embassy_time::Instant::now();

        init_heap();

        uart_puts(b"\n\0".as_ptr());
        let msg = format!("Hello World from Rust from hart {}!\n\0", hart_id());
        uart_puts(msg.as_ptr());

        let mut xs = Vec::new();
        xs.push(1);

        let msg = format!("Got value {} from the heap!\n\0", xs.pop().unwrap());
        uart_puts(msg.as_ptr());

        check_heap();

        let elapsed = embassy_time::Instant::now() - now;

        panic!(
            "This is a test panic, occurred after {} us",
            elapsed.as_micros()
        );
    }
}

fn uart_puts(s: *const u8) {
    unsafe {
        sys::MSS_UART_polled_tx_string(addr_of_mut!(sys::g_mss_uart0_lo), s);
    }
}

fn check_heap() {
    uart_puts(b"\nChecking heap integrity...\n\0".as_ptr());
    let heap_start = sys::last_linked_address();
    let heap_end = sys::last_address();

    let mut ptr = heap_start as *mut usize;
    while ptr < heap_end as *mut usize {
        unsafe {
            core::ptr::write_volatile(ptr, ptr as usize);
            let val = core::ptr::read_volatile(ptr);
            if val != ptr as usize {
                panic!("Heap corruption detected at {:#x}", ptr as usize);
            }
        }
        ptr = unsafe { ptr.add(0x1000) };
        uart_puts(b".\0".as_ptr());
    }
    uart_puts(format!("\nFinished! Checked {} bytes\n\0", heap_end - heap_start).as_ptr());
}

#![no_std]
#![feature(impl_trait_in_assoc_type)]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embassy_executor::Executor;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::blocking_mutex::Mutex;
use embassy_time::{Instant, Timer};
use embedded_alloc::LlffHeap as Heap;
use static_cell::StaticCell;

pub mod sys;
use sys::hart_id;

pub mod critical_section_impl;
pub mod time_driver;

critical_section::set_impl!(critical_section_impl::MPFSCriticalSection);

static EXECUTOR1: StaticCell<Executor> = StaticCell::new();

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
pub extern "C" fn u54_1() -> ! {
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
        time_driver::init();

        sys::raise_soft_interrupt(2);
        sys::raise_soft_interrupt(3);
        sys::raise_soft_interrupt(4);

        EXECUTOR1.init(Executor::new()).run(|spawner| {
            spawner.must_spawn(hart1_task());
        });

        #[allow(unreachable_code)]
        {
            panic!("This panic will occur of the executor stops (it should never stop)");
        }
    }
}

#[embassy_executor::task]
async fn hart1_task() {
    let now = Instant::now();
    uart_puts(b"\n\0".as_ptr());
    let msg = format!("Hello World from Rust from hart {}!\n\0", hart_id());
    uart_puts(msg.as_ptr());

    let mut xs = Vec::new();
    xs.push(1);

    let msg = format!("Got value {} from the heap!\n\0", xs.pop().unwrap());
    uart_puts(msg.as_ptr());

    loop {
        let elapsed = Instant::now() - now;
        let msg = format!("{} s\n\0", elapsed.as_secs());
        uart_puts(msg.as_ptr());
        Timer::after_millis(1000).await;
    }
}

//------------------------------------------------------------------------------------

#[no_mangle]
pub extern "C" fn u54_2() -> ! {
    unsafe {
        // Rest of hardware initialization
        sys::clear_soft_interrupt();
        core::arch::asm!("csrs mie, {}", const sys::MIP_MSIP, options(nomem, nostack));
        sys::PLIC_init();
        sys::__enable_irq();

        // Wait for the software interrupt
        core::arch::asm!("wfi", options(nomem, nostack));

        let msg = format!("Hart {} woke up!\n\0", hart_id());
        uart_puts(msg.as_ptr());

        loop {}
    }
}

#[no_mangle]
pub extern "C" fn u54_3() -> ! {
    unsafe {
        // Rest of hardware initialization
        sys::clear_soft_interrupt();
        core::arch::asm!("csrs mie, {}", const sys::MIP_MSIP, options(nomem, nostack));
        sys::PLIC_init();
        sys::__enable_irq();

        // Wait for the software interrupt
        core::arch::asm!("wfi", options(nomem, nostack));

        let msg = format!("Hart {} woke up!\n\0", hart_id());
        uart_puts(msg.as_ptr());

        loop {}
    }
}

#[no_mangle]
pub extern "C" fn u54_4() -> ! {
    unsafe {
        // Rest of hardware initialization
        sys::clear_soft_interrupt();
        core::arch::asm!("csrs mie, {}", const sys::MIP_MSIP, options(nomem, nostack));
        sys::PLIC_init();
        sys::__enable_irq();

        // Wait for the software interrupt
        core::arch::asm!("wfi", options(nomem, nostack));

        let msg = format!("Hart {} woke up!\n\0", hart_id());
        uart_puts(msg.as_ptr());

        loop {}
    }
}

//------------------------------------------------------------------------------------

static UART_MUTEX: Mutex<CriticalSectionRawMutex, ()> =
    Mutex::const_new(CriticalSectionRawMutex::new(), ());

fn uart_puts(s: *const u8) {
    critical_section::with(|cs| {
        let _guard = UART_MUTEX.borrow(cs);
        unsafe {
            sys::MSS_UART_polled_tx_string(addr_of_mut!(sys::g_mss_uart0_lo), s);
        }
    });
}

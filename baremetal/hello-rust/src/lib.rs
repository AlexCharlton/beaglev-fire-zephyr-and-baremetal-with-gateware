#![no_std]
#![feature(impl_trait_in_assoc_type)]

extern crate alloc;

use alloc::format;
use alloc::vec::Vec;
use core::panic::PanicInfo;
use core::ptr::addr_of_mut;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::blocking_mutex::Mutex;
use embassy_time::{Instant, Timer};
use embedded_alloc::LlffHeap as Heap;
use static_cell::StaticCell;

pub mod sys;
use sys::hart_id;

pub mod critical_section_impl;
pub mod embassy_executor_riscv;
pub mod time_driver;

use embassy_executor_riscv::Executor;

critical_section::set_impl!(critical_section_impl::MPFSCriticalSection);

static EXECUTOR1: StaticCell<Executor> = StaticCell::new();
static EXECUTOR2: StaticCell<Executor> = StaticCell::new();
static EXECUTOR3: StaticCell<Executor> = StaticCell::new();
static EXECUTOR4: StaticCell<Executor> = StaticCell::new();

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
        // We shouldn't rely on alloc/critical section while panicking
        uart_puts(b"\nPANIC at\0".as_ptr());
        uart_puts(location.file().as_bytes().as_ptr());
        uart_puts(b":\0".as_ptr());
        // Convert number to string
        let mut line_buf = [0u8; 10];
        let mut buf = itoa::Buffer::new();
        let num_str = buf.format(location.line());

        // Copy to our null-terminated buffer
        for (i, &byte) in num_str.as_bytes().iter().enumerate() {
            line_buf[i] = byte;
        }
        uart_puts(line_buf.as_ptr());
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
        let msg = format!("{} ms\n\0", elapsed.as_millis());
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

        EXECUTOR2.init(Executor::new()).run(|spawner| {
            spawner.must_spawn(hart2_task());
        });
    }
}

#[embassy_executor::task]
async fn hart2_task() {
    let msg = format!("Hart {} woke up!\n\0", hart_id());
    uart_puts(msg.as_ptr());
    Timer::after_millis(1500).await;
    let msg = format!("Hart {} again at {}\n\0", hart_id(), Instant::now());
    uart_puts(msg.as_ptr());
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

        EXECUTOR3.init(Executor::new()).run(|spawner| {
            spawner.must_spawn(hart3_task());
        });
    }
}

#[embassy_executor::task]
async fn hart3_task() {
    let msg = format!("Hart {} woke up!\n\0", hart_id());
    uart_puts(msg.as_ptr());
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

        EXECUTOR4.init(Executor::new()).run(|spawner| {
            spawner.must_spawn(hart4_task());
        });
    }
}

#[embassy_executor::task]
async fn hart4_task() {
    let msg = format!("Hart {} woke up!\n\0", hart_id());
    uart_puts(msg.as_ptr());
}

//------------------------------------------------------------------------------------

static UART_MUTEX: Mutex<CriticalSectionRawMutex, ()> =
    Mutex::const_new(CriticalSectionRawMutex::new(), ());

pub fn uart_puts(s: *const u8) {
    critical_section::with(|cs| {
        let _guard = UART_MUTEX.borrow(cs);
        unsafe {
            sys::MSS_UART_polled_tx_string(addr_of_mut!(sys::g_mss_uart0_lo), s);
        }
    });
}

pub fn uart_puts_no_lock(s: *const u8) {
    unsafe {
        sys::MSS_UART_polled_tx_string(addr_of_mut!(sys::g_mss_uart0_lo), s);
    }
}

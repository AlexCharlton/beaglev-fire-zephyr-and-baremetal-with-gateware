use core::cell::Cell;
use core::sync::atomic::{AtomicU8, Ordering};
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::blocking_mutex::Mutex;
use embassy_time_driver::{AlarmHandle, Driver};

use super::sys;

// Modelled off https://github.com/embassy-rs/embassy/blob/main/embassy-rp/src/time_driver.rs
// and https://github.com/polarfire-soc/polarfire-soc-bare-metal-examples/blob/main/driver-examples/mss/mss-timer/mpfs-timer-example/src/application/hart1/u54_1.c

struct AlarmState {
    timestamp: Cell<u64>,
    callback: Cell<Option<(fn(*mut ()), *mut ())>>,
}
unsafe impl Send for AlarmState {}

const ALARM_COUNT: usize = 1;
const TIMER_VS_MTIME_RATIO: u64 =
    sys::LIBERO_SETTING_MSS_APB_AHB_CLK as u64 / sys::LIBERO_SETTING_MSS_RTC_TOGGLE_CLK as u64;

struct TimeDriver {
    alarms: Mutex<CriticalSectionRawMutex, [AlarmState; ALARM_COUNT]>,
    next_alarm: AtomicU8,
}

embassy_time_driver::time_driver_impl!(static DRIVER: TimeDriver = TimeDriver {
    alarms: Mutex::const_new(CriticalSectionRawMutex::new(), [const{AlarmState {
        timestamp: Cell::new(0),
        callback: Cell::new(None),
    }}; ALARM_COUNT]),
    next_alarm: AtomicU8::new(0),
});

impl Driver for TimeDriver {
    fn now(&self) -> u64 {
        unsafe { sys::readmtime() }
    }

    unsafe fn allocate_alarm(&self) -> Option<AlarmHandle> {
        let id = self
            .next_alarm
            .fetch_update(Ordering::AcqRel, Ordering::Acquire, |x| {
                if x < ALARM_COUNT as u8 {
                    Some(x + 1)
                } else {
                    None
                }
            });

        match id {
            Ok(id) => Some(AlarmHandle::new(id)),
            Err(_) => None,
        }
    }

    fn set_alarm_callback(&self, alarm: AlarmHandle, callback: fn(*mut ()), ctx: *mut ()) {
        let n = alarm.id() as usize;
        critical_section::with(|cs| {
            let alarm = &self.alarms.borrow(cs)[n];
            alarm.callback.set(Some((callback, ctx)));
        })
    }

    fn set_alarm(&self, alarm: AlarmHandle, timestamp: u64) -> bool {
        let n = alarm.id() as usize;
        critical_section::with(|cs| {
            let alarm = &self.alarms.borrow(cs)[n];
            alarm.timestamp.set(timestamp);
            unsafe {
                let now = self.now();
                let diff = timestamp - now;
                let counter = diff * TIMER_VS_MTIME_RATIO;
                let load_value_u = (counter >> 32) as u32;
                let load_value_l = counter as u32;
                sys::MSS_TIM64_load_immediate(sys::TIMER_LO, load_value_u, load_value_l);
                sys::MSS_TIM64_start(sys::TIMER_LO);
                sys::MSS_TIM64_enable_irq(sys::TIMER_LO);
            }

            let now = self.now();
            if timestamp <= now {
                alarm.timestamp.set(u64::MAX);
                unsafe {
                    sys::MSS_TIM64_stop(sys::TIMER_LO);
                }
                false
            } else {
                true
            }
        })
    }
}

impl TimeDriver {
    fn trigger_alarm(&self) {
        critical_section::with(|cs| {
            let alarm = &self.alarms.borrow(cs)[0];
            alarm.timestamp.set(u64::MAX);
            unsafe {
                sys::MSS_TIM64_stop(sys::TIMER_LO);
            }
            // Call after clearing alarm, so the callback can set another alarm.
            if let Some((f, ctx)) = alarm.callback.get() {
                f(ctx);
            }
        });

        unsafe {
            sys::MSS_TIM64_clear_irq(sys::TIMER_LO);
        }
    }
}

/// Safety: must be called exactly once at bootup
pub unsafe fn init() {
    critical_section::with(|cs| {
        let alarms = DRIVER.alarms.borrow(cs);
        for a in alarms {
            a.timestamp.set(u64::MAX);
        }
    });

    unsafe {
        sys::mss_config_clk_rst(
            sys::mss_peripherals__MSS_PERIPH_TIMER,
            sys::MPFS_HAL_FIRST_HART as u8,
            sys::PERIPH_RESET_STATE__PERIPHERAL_ON,
        );
        sys::PLIC_SetPriority(sys::PLIC_IRQn_Type_PLIC_TIMER1_INT_OFFSET, 2);
        sys::PLIC_SetPriority(sys::PLIC_IRQn_Type_PLIC_TIMER2_INT_OFFSET, 2);
        sys::reset_mtime();
        sys::MSS_TIM64_init(sys::TIMER_LO, sys::__mss_timer_mode_MSS_TIMER_ONE_SHOT_MODE);
    }
}

#[no_mangle]
pub extern "C" fn PLIC_timer1_IRQHandler() -> u8 {
    DRIVER.trigger_alarm();

    return sys::EXT_IRQ_KEEP_ENABLED as u8;
}

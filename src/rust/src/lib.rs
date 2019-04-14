
#![no_std]
#![feature(alloc)]
#![feature(allocator_api)]
#![feature(alloc_error_handler)]
#![feature(lang_items)]


#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "eh_unwind_resume"] extern fn eh_unwind_resume() {}

extern crate freertos_rs;
extern crate cortex_m_semihosting;
extern crate cortex_m;
extern crate alloc;
extern crate panic_halt;

use cortex_m_semihosting::hprintln;
use freertos_rs::*;

pub mod freertos_alloc;
mod ctypes;

#[global_allocator]
static ALLOCATOR: freertos_alloc::FreeRTOSAlloc = freertos_alloc::FreeRTOSAlloc;

#[no_mangle]
pub extern fn application_idle_hook() {
}

#[no_mangle]
pub extern fn application_stack_overflow_hook() {
    panic!("StackOverflow");
}

#[no_mangle]
pub extern fn main_entry() {

    // Initialize the heap for FreeRTOS. Must be called before anything else, if using Heap_5!
    // unsafe { ALLOCATOR.init() }


    let check = shim_sanity_check();
	if check.is_err() {
        hprintln!("Shim sanity check failed: {:?}", check).unwrap();
	}

    Task::new().name("Task1").stack_size(512).start(|| {
        hprintln!("Hello from RUST new TASK! FreeRTOS looks good!").unwrap();
        loop {
            // CurrentTask::delay(Duration::ms(1000));
            hprintln!("\\\\\\\\\\ 1 ///// ").unwrap();
        }
    }).unwrap();

    Task::new().name("Task2").stack_size(512).start(|| {
        hprintln!("Hello from RUST TAKS2! FreeRTOS looks good!").unwrap();
        loop {
            // CurrentTask::delay(Duration::ms(10));
            hprintln!("///// 2 \\\\\\\\\\").unwrap();
        }
    }).unwrap();

    start_kernel();

    hprintln!("Should not hit here! EVER!").unwrap();

    loop {}
}

extern {
	fn vTaskStartScheduler();
}

pub fn start_kernel() {
	unsafe {
		vTaskStartScheduler();
	}
}


#[no_mangle]
pub extern fn __exidx_start() {
    loop {}
}

#[no_mangle]
pub extern fn __exidx_end() {
    loop {}
}

#[no_mangle]
pub extern fn _kill() {
    loop {}
}

#[no_mangle]
pub extern fn _exit() {
    loop {}
}

#[no_mangle]
pub extern fn _getpid() {
    loop {}
}

#![no_std]

#![feature(alloc)]
#![feature(allocator_api)]
#![feature(alloc_error_handler)]
#![feature(lang_items)]


#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "eh_unwind_resume"] extern fn eh_unwind_resume() {}

extern crate freertos_rs;
extern crate cortex_m_semihosting;
extern crate alloc;
extern crate panic_halt;

use cortex_m_semihosting::hprintln;
use self::alloc::vec;
use freertos_rs::*;

pub mod freertos_alloc;
mod ctypes;

#[global_allocator]
static ALLOCATOR: freertos_alloc::FreeRTOSAlloc = freertos_alloc::FreeRTOSAlloc;

#[no_mangle]
pub extern fn main_entry() {

    // Initialize the heap for FreeRTOS. We are using Heap_5 because the RAM is not contiguous.
    unsafe { ALLOCATOR.init() }

    // let xs = vec![0, 1, 2];

    let check = shim_sanity_check();
	if check.is_err() {
        hprintln!("Shim sanity check failed: {:?}", check).unwrap();
	}


    let mut n = 0;

    loop {
        n = n + 5;
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

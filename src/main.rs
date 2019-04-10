#![feature(alloc)]
#![feature(alloc_error_handler)]
#![no_main]
#![no_std]

extern crate cortex_m;
extern crate alloc_cortex_m;
extern crate alloc;
extern crate cortex_m_rt;
extern crate cortex_m_semihosting;
// extern crate stm32l4xx_hal as hal;
// extern crate freertos_rs;

use self::alloc::vec;
use core::alloc::Layout;

// use freertos_rs::*;

use alloc_cortex_m::CortexMHeap;
// use crate::hal::prelude::*;
// use crate::hal::delay::Delay;
// use crate::rt::ExceptionFrame;
use cortex_m_rt::entry;
use cortex_m::asm;
use cortex_m_semihosting::hprintln;

use core::panic::PanicInfo;

// use core::fmt::Write;
// use crate::sh::hio;

#[global_allocator]
static ALLOCATOR: CortexMHeap = CortexMHeap::empty();

const HEAP_SIZE: usize = 1024; // in bytes

#[entry]
fn main() -> ! {

    unsafe { ALLOCATOR.init(cortex_m_rt::heap_start() as usize, HEAP_SIZE) }

    // if shim_sanity_check().is_err() {
    //     hprintln!("Error!").unwrap();
    // }


    let xs = vec![0, 1, 2];

    hprintln!("{:?}", xs).unwrap();

    // let mut hstdout = hio::hstdout().unwrap();

    // writeln!(hstdout, "Hello, world!").unwrap();

    loop {}

    // let cp = cortex_m::Peripherals::take().unwrap();
    // let dp = hal::stm32::Peripherals::take().unwrap();

    // let mut flash = dp.FLASH.constrain();
    // let mut rcc = dp.RCC.constrain();

    // // Try a different clock configuration
    // let clocks = rcc.cfgr.hclk(8.mhz()).freeze(&mut flash.acr);
    // // let clocks = rcc.cfgr
    // //     .sysclk(64.mhz())
    // //     .pclk1(32.mhz())
    // //     .freeze(&mut flash.acr);


    // let mut gpioa = dp.GPIOA.split(&mut rcc.ahb2);
    // let mut led = gpioa.pa5.into_push_pull_output(&mut gpioa.moder, &mut gpioa.otyper);

    // let mut timer = Delay::new(cp.SYST, clocks);
    // loop {
    //     // block!(timer.wait()).unwrap();
    //     timer.delay_ms(1000 as u32);
    //     led.set_high();
    //     // block!(timer.wait()).unwrap();
    //     timer.delay_ms(1000 as u32);
    //     led.set_low();
    // }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[alloc_error_handler]
fn alloc_error(_layout: Layout) -> ! {
    asm::bkpt();

    loop {}
}

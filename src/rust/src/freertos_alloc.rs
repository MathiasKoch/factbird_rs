

extern crate cortex_m;
extern crate alloc;
extern crate cortex_m_semihosting;

use cortex_m_semihosting::hprintln;
use core::alloc::{GlobalAlloc, Layout};
use ctypes::c_void;

// #[repr(C)]
// struct HeapRegion {
//   start_address: *const u8,
// 	size_in_bytes: usize,
// }

extern {
    fn pvPortMalloc(size: u32) -> *mut c_void;
    // fn pvPortRealloc(p: *mut c_void, size: u32) -> *mut c_void;
    fn vPortFree(p: *mut c_void);
    // fn vPortDefineHeapRegions(heapRegions: &[HeapRegion]);
}

// define what happens in an Out Of Memory (OOM) condition
#[alloc_error_handler]
fn alloc_error(layout: Layout) -> ! {
    hprintln!("OOM {:?}", layout).unwrap();
    panic!("OOM");
}

pub struct FreeRTOSAlloc;

// impl FreeRTOSAlloc {
//     pub unsafe fn init(&self) {

//       // const HEAP1_SIZE: usize = 110 * 1024;
//       const HEAP2_SIZE: usize = 27 * 1024;

//       // static HEAP1: &'static [u8] = &[ 0; HEAP1_SIZE ];

//       // #[link_section = ".freertos_heap2"]
//       static HEAP2: &'static [u8] = &[ 0; HEAP2_SIZE ];

//       // hprintln!("HEAP1: {:?}, size: {:?}", HEAP1.as_ptr(), mem::size_of::<[u8;HEAP1_SIZE]>()).unwrap();
//       hprintln!("HEAP2: {:?}, size: {:?}", HEAP2.as_ptr(), mem::size_of::<[u8;HEAP2_SIZE]>()).unwrap();

//       let heap_regions =
//       [
//           HeapRegion { start_address: HEAP2.as_ptr(), size_in_bytes: mem::size_of::<[u8;HEAP2_SIZE]>() },
//           // HeapRegion { start_address: HEAP1.as_ptr(), size_in_bytes: mem::size_of::<[u8;HEAP1_SIZE]>() },
//           HeapRegion { start_address: ptr::null(), size_in_bytes: 0 }
//       ];

//       vPortDefineHeapRegions(&heap_regions)
//     }
// }

unsafe impl GlobalAlloc for FreeRTOSAlloc {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
      pvPortMalloc(layout.size() as u32) as *mut u8
    }

    unsafe fn dealloc(&self, ptr: *mut u8, _layout: Layout) {
      vPortFree(ptr as *mut c_void)
    }
}

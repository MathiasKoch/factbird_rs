MEMORY
{
  /* NOTE 1 K = 1 KiBi = 1024 bytes */
  RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 96K
  RAM2 (xrw)      : ORIGIN = 0x10000000, LENGTH = 32K
  FLASH (rx)      : ORIGIN = 0x08000000, LENGTH = 464K    /* Use only the first bank */
  FLASH_UC (r)	  : ORIGIN = 0x08074000, LENGTH = 9K		  /* Fixed-location area */
}

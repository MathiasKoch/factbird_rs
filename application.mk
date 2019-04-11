
# Initialize tool chain
# -------------------------------------------------------------------
# AMEBA_TOOLDIR	= component/soc/realtek/8195a/misc/iar_utility/common/tools/

CROSS_COMPILE = arm-none-eabi-

# Compilation tools
AR = $(CROSS_COMPILE)ar
CC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
NM = $(CROSS_COMPILE)nm
LD = $(CROSS_COMPILE)gcc
GDB = $(CROSS_COMPILE)gdb
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

# PICK = $(AMEBA_TOOLDIR)pick
# PAD  = $(AMEBA_TOOLDIR)padding
# CHKSUM = $(AMEBA_TOOLDIR)checksum

# Initialize target name and target object files
# -------------------------------------------------------------------

all: application

TARGET=application

OBJ_DIR=$(TARGET)/Debug/obj
BIN_DIR=$(TARGET)/Debug/bin
RUST_OBJ_DIR=$(TARGET)/Debug/rust_obj

# Include folder list
# -------------------------------------------------------------------

INCLUDES =
INCLUDES += -Isrc/c/inc
INCLUDES += -Ivendor/amazon-freertos/lib/include
INCLUDES += -Ivendor/amazon-freertos/lib/include/private
INCLUDES += -Ivendor/amazon-freertos/lib/FreeRTOS/portable/GCC/ARM_CM3
INCLUDES += -Ivendor/amazon-freertos/lib/third_party/mcu_vendor/st/stm32l475_discovery/CMSIS/Include
INCLUDES += -Ivendor/amazon-freertos/lib/third_party/mcu_vendor/st/stm32l475_discovery/CMSIS/Device/ST/STM32L4xx/Include

# Source file list
# -------------------------------------------------------------------

SRC_C =
#cmsis
SRC_C += vendor/amazon-freertos/lib/third_party/mcu_vendor/st/stm32l475_discovery/CMSIS/system_stm32l4xx.c

#os - freertos
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/portable/MemMang/heap_5.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/portable/GCC/ARM_CM4F/port.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/event_groups.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/list.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/queue.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/stream_buffer.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/tasks.c
SRC_C += vendor/amazon-freertos/lib/FreeRTOS/timers.c

# SRC_C += vendor/amazon-freertos/lib/FreeRTOS/cmsis_os.c

#user
SRC_C += src/c/src/main.c

SRC_ASM =
SRC_ASM += src/c/src/startup_stm32l475xx.s

# Generate obj list
# -------------------------------------------------------------------

SRC_O = $(patsubst %.c,%.o,$(SRC_C))
SRC_ASM_O = $(patsubst %.s,%.o,$(SRC_ASM))

SRC_C_LIST = $(notdir $(SRC_C))
SRC_ASM_LIST = $(notdir $(SRC_ASM))

OBJ_LIST = $(addprefix $(OBJ_DIR)/,$(patsubst %.c,%.o,$(SRC_C_LIST))) $(addprefix $(OBJ_DIR)/,$(patsubst %.s,%.o,$(SRC_ASM_LIST)))

# Rust lib
OBJ_LIST += $(RUST_OBJ_DIR)/librustfactbird.o $(RUST_OBJ_DIR)/libfreertos_rs.o

DEPENDENCY_LIST = $(addprefix $(OBJ_DIR)/,$(patsubst %.c,%.d,$(SRC_C_LIST))) $(addprefix $(OBJ_DIR)/,$(patsubst %.s,%.d,$(SRC_ASM_LIST)))

# Compile options
# -------------------------------------------------------------------

CFLAGS =
CFLAGS += -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard -DSTM32L475xx -O3 -Wall -fdata-sections -ffunction-sections -std=gnu11
# -mcpu=cortex-m4 -mthumb -g2 -w -O2 -Wno-pointer-sign -fno-common -fmessage-length=0  -ffunction-sections -fdata-sections -fomit-frame-pointer -fno-short-enums -mcpu=cortex-m4 -DF_CPU=166000000L -std=gnu99 -fsigned-char

LFLAGS =
LFLAGS += -mcpu=cortex-m4 -mthumb -g -mfpu=fpv4-sp-d16 -mfloat-abi=hard --specs=nano.specs -Wl,-Map=$(BIN_DIR)/${TARGET}.map -Os -Wl,--gc-sections -Wl,--cref -Wl,--no-enum-size-warning -Wl,--no-wchar-size-warning

LIBFLAGS =
all: LIBFLAGS += -lm -lc -lnosys

# Compile
# -------------------------------------------------------------------

.PHONY: application
application: prerequirement build_info $(SRC_O) $(SRC_ASM_O)
	$(LD) $(LFLAGS) -o $(BIN_DIR)/$(TARGET).elf  $(OBJ_LIST) $(LIBFLAGS) -Tlinkers/STM32L475VGTx_FLASH.ld

# $(OBJDUMP) -d $(BIN_DIR)/$(TARGET).elf > $(BIN_DIR)/$(TARGET).asm

# Generate build info
# -------------------------------------------------------------------

.PHONY: build_info
build_info:
	@echo \#define UTS_VERSION \"`date +%Y/%m/%d-%T`\" > .ver
	@echo \#define RTL8195AFW_COMPILE_TIME \"`date +%Y/%m/%d-%T`\" >> .ver
	@echo \#define RTL8195AFW_COMPILE_DATE \"`date +%Y%m%d`\" >> .ver
	@echo \#define RTL8195AFW_COMPILE_BY \"`id -u -n`\" >> .ver
	@echo \#define RTL8195AFW_COMPILE_HOST \"`$(HOSTNAME_APP)`\" >> .ver
	@if [ -x /bin/dnsdomainname ]; then \
		echo \#define RTL8195AFW_COMPILE_DOMAIN \"`dnsdomainname`\"; \
	elif [ -x /bin/domainname ]; then \
		echo \#define RTL8195AFW_COMPILE_DOMAIN \"`domainname`\"; \
	else \
		echo \#define RTL8195AFW_COMPILE_DOMAIN ; \
	fi >> .ver

	@echo \#define RTL195AFW_COMPILER \"gcc `$(CC) $(CFLAGS) -dumpversion | tr --delete '\r'`\" >> .ver
	@mv -f .ver src/c/inc/$@.h


.PHONY: prerequirement
prerequirement:
	@echo ===========================================================
	@echo Build $(TARGET)
	@echo ===========================================================
	mkdir -p $(OBJ_DIR)
	mkdir -p $(BIN_DIR)

$(SRC_O): %.o : %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -MM -MT $@ -MF $(OBJ_DIR)/$(notdir $(patsubst %.o,%.d,$@))
	mv $@ $(OBJ_DIR)/$(notdir $@)
	chmod 777 $(OBJ_DIR)/$(notdir $@)

$(SRC_ASM_O): %.o : %.s
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -MM -MT $@ -MF $(OBJ_DIR)/$(notdir $(patsubst %.o,%.d,$@))
	mv $@ $(OBJ_DIR)/$(notdir $@)
	chmod 777 $(OBJ_DIR)/$(notdir $@)

-include $(DEPENDENCY_LIST)

# Generate build info
# -------------------------------------------------------------------
#ifeq (setup,$(firstword $(MAKECMDGOALS)))
#  # use the rest as arguments for "run"
#  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
#  # ...and turn them into do-nothing targets
#  $(eval $(RUN_ARGS):;@:)
#endif
# .PHONY: setup
# setup:
# 	@echo "----------------"
# 	@echo Setup $(GDB_SERVER)
# 	@echo "----------------"
# ifeq ($(GDB_SERVER), openocd)
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_debug_openocd.txt $(FLASH_TOOLDIR)/rtl_gdb_debug.txt
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_ramdebug_openocd.txt $(FLASH_TOOLDIR)/rtl_gdb_ramdebug.txt
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_flash_write_openocd.txt $(FLASH_TOOLDIR)/rtl_gdb_flash_write.txt
# else
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_debug_jlink.txt $(FLASH_TOOLDIR)/rtl_gdb_debug.txt
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_ramdebug_jlink.txt $(FLASH_TOOLDIR)/rtl_gdb_ramdebug.txt
# 	cp -p $(FLASH_TOOLDIR)/rtl_gdb_flash_write_jlink.txt $(FLASH_TOOLDIR)/rtl_gdb_flash_write.txt
# endif

# .PHONY: flashburn
# flashburn:
# 	@if [ ! -f $(FLASH_TOOLDIR)/rtl_gdb_flash_write.txt ] ; then echo Please do \"make setup GDB_SERVER=[jlink or openocd]\" first; echo && false ; fi
# ifeq ($(findstring CYGWIN, $(OS)), CYGWIN)
# 	$(FLASH_TOOLDIR)/Check_Jtag.sh
# endif
# 	cp	$(FLASH_TOOLDIR)/target_NORMALB.axf $(FLASH_TOOLDIR)/target_NORMAL.axf
# 	chmod 777 $(FLASH_TOOLDIR)/target_NORMAL.axf
# 	chmod +rx $(FLASH_TOOLDIR)/SetupGDB_NORMAL.sh
# 	$(FLASH_TOOLDIR)/SetupGDB_NORMAL.sh
# 	$(GDB) -x $(FLASH_TOOLDIR)/rtl_gdb_flash_write.txt

# .PHONY: debug
# debug:
# 	@if [ ! -f $(FLASH_TOOLDIR)/rtl_gdb_debug.txt ] ; then echo Please do \"make setup GDB_SERVER=[jlink or openocd]\" first; echo && false ; fi
# ifeq ($(findstring CYGWIN, $(OS)), CYGWIN)
# 	$(FLASH_TOOLDIR)/Check_Jtag.sh
# 	cmd /c start $(GDB) -x $(FLASH_TOOLDIR)/rtl_gdb_debug.txt
# else
# 	$(GDB) -x $(FLASH_TOOLDIR)/rtl_gdb_debug.txt
# endif

# .PHONY: ramdebug
# ramdebug:
# 	@if [ ! -f $(FLASH_TOOLDIR)/rtl_gdb_ramdebug.txt ] ; then echo Please do \"make setup GDB_SERVER=[jlink or openocd]\" first; echo && false ; fi
# ifeq ($(findstring CYGWIN, $(OS)), CYGWIN)
# 	$(FLASH_TOOLDIR)/Check_Jtag.sh
# 	cmd /c start $(GDB) -x $(FLASH_TOOLDIR)/rtl_gdb_ramdebug.txt
# else
# 	$(GDB) -x $(FLASH_TOOLDIR)/rtl_gdb_ramdebug.txt
# endif

.PHONY: clean
clean:
	rm -rf $(TARGET)
	rm -f $(SRC_O)
	rm -f $(SRC_ASM_O)
	rm -f $(patsubst %.o,%.d,$(SRC_ASM_O))

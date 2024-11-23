################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/mpfs_hal/common/nwc/mss_cfm.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr_debug.c \
../src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.c \
../src/platform/mpfs_hal/common/nwc/mss_io.c \
../src/platform/mpfs_hal/common/nwc/mss_nwc_init.c \
../src/platform/mpfs_hal/common/nwc/mss_pll.c \
../src/platform/mpfs_hal/common/nwc/mss_sgmii.c 

OBJS += \
./src/platform/mpfs_hal/common/nwc/mss_cfm.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr_debug.o \
./src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.o \
./src/platform/mpfs_hal/common/nwc/mss_io.o \
./src/platform/mpfs_hal/common/nwc/mss_nwc_init.o \
./src/platform/mpfs_hal/common/nwc/mss_pll.o \
./src/platform/mpfs_hal/common/nwc/mss_sgmii.o 

C_DEPS += \
./src/platform/mpfs_hal/common/nwc/mss_cfm.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr_debug.d \
./src/platform/mpfs_hal/common/nwc/mss_ddr_test_pattern.d \
./src/platform/mpfs_hal/common/nwc/mss_io.d \
./src/platform/mpfs_hal/common/nwc/mss_nwc_init.d \
./src/platform/mpfs_hal/common/nwc/mss_pll.d \
./src/platform/mpfs_hal/common/nwc/mss_sgmii.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/mpfs_hal/common/nwc/%.o: ../src/platform/mpfs_hal/common/nwc/%.c src/platform/mpfs_hal/common/nwc/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -DNDEBUG -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\application" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire\platform_config" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\platform" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/drivers/fpga_ip/CoreMMC/core_mmc.c \
../src/platform/drivers/fpga_ip/CoreMMC/core_mmc_if.c 

OBJS += \
./src/platform/drivers/fpga_ip/CoreMMC/core_mmc.o \
./src/platform/drivers/fpga_ip/CoreMMC/core_mmc_if.o 

C_DEPS += \
./src/platform/drivers/fpga_ip/CoreMMC/core_mmc.d \
./src/platform/drivers/fpga_ip/CoreMMC/core_mmc_if.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/drivers/fpga_ip/CoreMMC/%.o: ../src/platform/drivers/fpga_ip/CoreMMC/%.c src/platform/drivers/fpga_ip/CoreMMC/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -DNDEBUG -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\application" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire\platform_config" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\platform" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



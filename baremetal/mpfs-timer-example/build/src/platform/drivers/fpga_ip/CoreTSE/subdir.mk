################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/drivers/fpga_ip/CoreTSE/core_tse.c \
../src/platform/drivers/fpga_ip/CoreTSE/crc32.c \
../src/platform/drivers/fpga_ip/CoreTSE/m88e1111_phy.c \
../src/platform/drivers/fpga_ip/CoreTSE/m88e1340_phy.c \
../src/platform/drivers/fpga_ip/CoreTSE/null_phy.c \
../src/platform/drivers/fpga_ip/CoreTSE/vsc8575.c 

OBJS += \
./src/platform/drivers/fpga_ip/CoreTSE/core_tse.o \
./src/platform/drivers/fpga_ip/CoreTSE/crc32.o \
./src/platform/drivers/fpga_ip/CoreTSE/m88e1111_phy.o \
./src/platform/drivers/fpga_ip/CoreTSE/m88e1340_phy.o \
./src/platform/drivers/fpga_ip/CoreTSE/null_phy.o \
./src/platform/drivers/fpga_ip/CoreTSE/vsc8575.o 

C_DEPS += \
./src/platform/drivers/fpga_ip/CoreTSE/core_tse.d \
./src/platform/drivers/fpga_ip/CoreTSE/crc32.d \
./src/platform/drivers/fpga_ip/CoreTSE/m88e1111_phy.d \
./src/platform/drivers/fpga_ip/CoreTSE/m88e1340_phy.d \
./src/platform/drivers/fpga_ip/CoreTSE/null_phy.d \
./src/platform/drivers/fpga_ip/CoreTSE/vsc8575.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/drivers/fpga_ip/CoreTSE/%.o: ../src/platform/drivers/fpga_ip/CoreTSE/%.c src/platform/drivers/fpga_ip/CoreTSE/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -DNDEBUG -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\application" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire\platform_config" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\platform" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



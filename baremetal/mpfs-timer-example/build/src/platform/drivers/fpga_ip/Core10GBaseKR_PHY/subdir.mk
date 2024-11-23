################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy.c \
../src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy_link_training.c 

OBJS += \
./src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy.o \
./src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy_link_training.o 

C_DEPS += \
./src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy.d \
./src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/core10gbasekr_phy_link_training.d 


# Each subdirectory must supply rules for building sources it contributes
src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/%.o: ../src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/%.c src/platform/drivers/fpga_ip/Core10GBaseKR_PHY/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -DNDEBUG -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\application" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire\platform_config" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\platform" -I"C:\programming\SoftConsole\polarfire-soc-bare-metal-examples\driver-examples\mss\mss-timer\mpfs-timer-example\src\boards\beaglev-fire" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '



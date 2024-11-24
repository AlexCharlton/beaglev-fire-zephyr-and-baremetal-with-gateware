.DEFAULT_GOAL := all

BUILD_DIR := build
PLATFORM_DIR := mpfs-platform

# Recursively find all C source files under ${PLATFORM_DIR}, excluding ethernet_mac
C_SRCS := $(shell find mpfs-platform -type f -name "*.c" ! \( -path "mpfs-platform/platform/drivers/mss/*" -a ! \( -path "mpfs-platform/platform/drivers/mss/mss_mmuart/*" -o -path "mpfs-platform/platform/drivers/mss/mss_gpio/*" \) \) )
# Convert source paths to object paths under build/
OBJS := $(C_SRCS:%.c=$(BUILD_DIR)/%.o)
# Generate dependency file paths
C_DEPS := $(OBJS:%.o=%.d)

S_UPPER_SRCS += ${PLATFORM_DIR}/platform/mpfs_hal/startup_gcc/mss_entry.S \
	${PLATFORM_DIR}/platform/mpfs_hal/startup_gcc/mss_utils.S \
	${PLATFORM_DIR}/platform/hal/hw_reg_access.S
S_UPPER_DEPS += $(S_UPPER_SRCS:%.S=%.d)
OBJS += $(BUILD_DIR)/${PLATFORM_DIR}/platform/mpfs_hal/startup_gcc/mss_entry.o \
	$(BUILD_DIR)/${PLATFORM_DIR}/platform/mpfs_hal/startup_gcc/mss_utils.o \
	$(BUILD_DIR)/${PLATFORM_DIR}/platform/hal/hw_reg_access.o

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

BUILD_ARTIFACT_NAME := hello-rust
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
ELF_TARGET := $(BUILD_DIR)/$(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

SECONDARY_FLASH += \
$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).bin \

SECONDARY_LIST += \
$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).lst \

SECONDARY_SIZE += \
$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).siz \

IMG_TARGET := $(BUILD_DIR)/application.img

RUST_TARGET := target/riscv64gc-unknown-none-elf/release/libapplication.a
#OBJS += $(RUST_TARGET)

# All Target
all:
	$(MAKE) --no-print-directory main-build

# Main-build Target
main-build: rust-build $(ELF_TARGET) secondary-outputs $(IMG_TARGET)

rust-build:
	cargo build --release

# Tool invocations
$(ELF_TARGET): $(OBJS) makefile
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -T "${PLATFORM_DIR}/platform/platform_config_reference/linker/mpfs-ddr-loaded-by-boot-loader.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"${BUILD_DIR}/$(BUILD_ARTIFACT_NAME).map" --specs=nano.specs --specs=nosys.specs -o "$(ELF_TARGET)" $(OBJS)  $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).bin: $(ELF_TARGET) makefile
	@echo 'Invoking: GNU RISC-V Cross Create Flash Image'
	riscv64-unknown-elf-objcopy -O binary "$(ELF_TARGET)" "$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).bin"
	@echo 'Finished building: $@'
	@echo ' '

$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).lst: $(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).elf makefile
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv64-unknown-elf-objdump --source --all-headers --demangle --line-numbers --wide "$(ELF_TARGET)" > "$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).lst"
	@echo 'Finished building: $@'
	@echo ' '

$(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).siz: $(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).elf makefile
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv64-unknown-elf-size --format=sysv --totals --radix=16 "$(ELF_TARGET)"
	@echo 'Finished building: $@'
	@echo ' '

$(IMG_TARGET): $(ELF_TARGET)
	hss-payload-generator -c image-conf.yaml $(IMG_TARGET)

# Other Targets
clean:
	-$(RM) $(OBJS)$(SECONDARY_FLASH)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(S_UPPER_DEPS)$(C_DEPS) $(BUILD_DIR)/$(BUILD_ARTIFACT_NAME).elf
	-@echo ' '

secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

# Generic rule for building any C source file
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -DNDEBUG -I"${PLATFORM_DIR}/application" -I"${PLATFORM_DIR}/boards/beaglev-fire/platform_config" -I"${PLATFORM_DIR}/platform" -I"${PLATFORM_DIR}/boards/beaglev-fire" -std=gnu11 -Wstrict-prototypes -Wbad-function-cast -Wa,-adhlns="$@.lst" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

# Add rule for assembling .S files
$(BUILD_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo 'Building file: $<'
	riscv64-unknown-elf-gcc -march=rv64gc -mabi=lp64d -mcmodel=medany -msmall-data-limit=8 -mstrict-align -mno-save-restore -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections  -g -x assembler-with-cpp -DNDEBUG -I"${PLATFORM_DIR}/application" -I"${PLATFORM_DIR}/boards/beaglev-fire/platform_config" -I"${PLATFORM_DIR}/platform" -I"${PLATFORM_DIR}/boards/beaglev-fire" --specs=nano.specs -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

.PHONY: all clean dependents main-build pre-build

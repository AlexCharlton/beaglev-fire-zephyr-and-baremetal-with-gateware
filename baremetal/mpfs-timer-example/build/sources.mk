ELF_SRCS :=
OBJ_SRCS :=
ASM_SRCS :=
C_SRCS :=
S_UPPER_SRCS :=
O_SRCS :=
OBJS :=
SECONDARY_FLASH :=
SECONDARY_LIST :=
SECONDARY_SIZE :=
ASM_DEPS :=
S_UPPER_DEPS :=
C_DEPS :=

# Every subdirectory with source files must be described here
SUBDIRS := \
src/application/hart1 \
src/application/hart2 \
src/application/hart3 \
src/application/hart4 \
src/platform/drivers/fpga_ip/Core10GBaseKR_PHY \
src/platform/drivers/fpga_ip/CoreGPIO \
src/platform/drivers/fpga_ip/CoreI2C \
src/platform/drivers/fpga_ip/CoreMMC \
src/platform/drivers/fpga_ip/CorePWM \
src/platform/drivers/fpga_ip/CoreQSPI \
src/platform/drivers/fpga_ip/CoreSPI \
src/platform/drivers/fpga_ip/CoreSysServices_PF \
src/platform/drivers/fpga_ip/CoreTSE \
src/platform/drivers/fpga_ip/CoreTimer \
src/platform/drivers/fpga_ip/CoreUARTapb \
src/platform/drivers/mss/mss_gpio \
src/platform/drivers/mss/mss_mmuart \
src/platform/hal \
src/platform/mpfs_hal/common \
src/platform/mpfs_hal/common/nwc \
src/platform/mpfs_hal/startup_gcc \

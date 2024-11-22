# Zephyr workspace directory
# If using Windows, this should be a WSL directory
ZEPHYR_WORKSPACE=~/zephyrproject

# Gateware config file, relative to project root
GATEWARE_CONFIG_FILE=gateware/blinky.yaml

# Zephyr-rust directory
ZEPHYR_RUST_DIR=~/src/zephyr-rust

#===============================================================================
# Edit the following section with the location where the following tools are
# installed:
#   - SoftConsole (SC_INSTALL_DIR)
#   - Libero (LIBERO_INSTALL_DIR)
#===============================================================================
export SC_INSTALL_DIR=/c/Microchip/SoftConsole-v2022.2-RISC-V-747
export LIBERO_INSTALL_DIR=/c/Microchip/Libero_SoC_v2024.1
export LM_LICENSE_FILE=/c/Microchip/flexlm/License.dat


#===============================================================================
# Don't edit below this line
#===============================================================================
# SoftConsole
export PATH=$PATH:$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin
export FPGENPROG=$LIBERO_INSTALL_DIR/Designer/bin64/fpgenprog.exe

# Libero
export PATH=$PATH:$LIBERO_INSTALL_DIR/Designer/bin:$LIBERO_INSTALL_DIR/Designer/bin64
export PATH=$PATH:$LIBERO_INSTALL_DIR/SynplifyPro/bin
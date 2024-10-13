#!/bin/bash

#===============================================================================
# Edit the following section with the location where the following tools are
# installed:
#   - SoftConsole (SC_INSTALL_DIR)
#   - Libero (LIBERO_INSTALL_DIR)
#===============================================================================
export SC_INSTALL_DIR=/c/Microchip/SoftConsole-v2022.2-RISC-V-747
export LIBERO_INSTALL_DIR=/c/Microchip/Libero_SoC_v2024.1

#
# SoftConsole
#
export PATH=$PATH:$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin
export FPGENPROG=$LIBERO_INSTALL_DIR/Designer/bin64/fpgenprog.exe

#
# Libero
#
export PATH=$PATH:$LIBERO_INSTALL_DIR/Designer/bin:$LIBERO_INSTALL_DIR/Designer/bin64
export PATH=$PATH:$LIBERO_INSTALL_DIR/SynplifyPro/bin

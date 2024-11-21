#!/bin/bash

set -e

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

$SC_INSTALL_DIR/riscv-unknown-elf-gcc/bin/riscv64-unknown-elf-gdb -x $PROJECT_DIR/scripts/init.gdb $PROJECT_DIR/build/zephyr.elf
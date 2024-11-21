#!/bin/bash

set -e

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

$SC_INSTALL_DIR/openocd/bin/openocd.exe -c "bindto 0.0.0.0" -c "adapter_khz 1000" --command "set DEVICE MPFS" --file $SC_INSTALL_DIR/openocd/share/openocd/scripts/board/microsemi-riscv.cfg
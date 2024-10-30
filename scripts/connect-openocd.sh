#!/bin/bash

/c/Microchip/SoftConsole-v2022.2-RISC-V-747/openocd/bin/openocd.exe -c "bindto 0.0.0.0" -c "adapter_khz 1000" --command "set DEVICE MPFS" --file /c/Microchip/SoftConsole-v2022.2-RISC-V-747/openocd/share/openocd/scripts/board/microsemi-riscv.cfg
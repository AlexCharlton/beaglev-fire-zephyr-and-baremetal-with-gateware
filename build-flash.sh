#/bin/bash

set -e

/c/programming/beaglev/build.bat
dd if=//wsl\$/Ubuntu/home/alex/zephyr.img of=/dev/sdd1  bs=4M status=progress oflag=sync
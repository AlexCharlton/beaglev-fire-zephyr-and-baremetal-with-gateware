
#/bin/bash

set -e

dd if=//wsl\$/Ubuntu/home/alex/zephyr.img of=/dev/sdd1  bs=4M status=progress oflag=sync
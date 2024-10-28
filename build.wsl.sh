#!/bin/bash

set -e # Exit on error

cd ~/zephyrproject/zephyr
source ~/zephyrproject/.venv/bin/activate

# west build -p always -b beaglev_fire/polarfire/u54/smp samples/hello_world
west build -p always -b beaglev_fire/polarfire/u54 samples/hello_world

cd ~
~/bin/hss-payload-generator -c /mnt/c/programming/beaglev/image-conf.yaml zephyr.img

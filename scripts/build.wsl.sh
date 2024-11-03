#!/bin/bash

set -e # Exit on error

ZEPHYR_WORKSPACE=~/zephyrproject

cd $ZEPHYR_WORKSPACE
source .venv/bin/activate
rsync -a --delete /mnt/c/programming/beaglev/app/ ~/zephyr-app

# west build -p always -b beaglev_fire/polarfire/u54/smp samples/hello_world
west build -p always -b beaglev_fire/polarfire/u54 -s ~/zephyr-app

cd ~
~/bin/hss-payload-generator -c /mnt/c/programming/beaglev/image-conf.yaml $ZEPHYR_WORKSPACE/build/zephyr.img
mkdir -p /mnt/c/programming/beaglev/build
rsync -a $ZEPHYR_WORKSPACE/build/zephyr.img /mnt/c/programming/beaglev/build
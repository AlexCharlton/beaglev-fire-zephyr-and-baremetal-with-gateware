#!/bin/bash

source ~/.profile
# Current directory that this script is in
PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..

set -e # Exit on error

# Check if exactly one argument was provided
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one app name as argument"
    exit 1
fi

# Check if app directory exists
if [ ! -d "$PROJECT_DIR/apps/$1" ]; then
    echo "Error: App directory '$1' not found in apps/"
    exit 1
fi

APP_NAME=$1
ZEPHYR_WORKSPACE=~/zephyrproject
mkdir -p $ZEPHYR_WORKSPACE/applications

cd $ZEPHYR_WORKSPACE
source .venv/bin/activate
rsync -a --delete $PROJECT_DIR/apps/ $ZEPHYR_WORKSPACE/applications/

west build -p always -b beaglev_fire/polarfire/u54/smp -s $ZEPHYR_WORKSPACE/applications/$APP_NAME

cd $ZEPHYR_WORKSPACE/build/zephyr
hss-payload-generator -c $PROJECT_DIR/image-conf.yaml zephyr.img
mkdir -p $PROJECT_DIR/build
rsync -a $ZEPHYR_WORKSPACE/build/zephyr/zephyr.* $PROJECT_DIR/build
echo "Build complete"
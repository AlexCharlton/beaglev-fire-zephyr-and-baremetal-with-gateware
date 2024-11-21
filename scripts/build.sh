#!/bin/bash

set -e # Exit on error

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..

# Check if running in MinGW/MSYS
if [[ "$(uname -s)" == *"MINGW"* ]]; then
    # If so, create a batch file that will run the script in WSL
    # Why the batch file? Otherwise, MSYS will try rewrite the directory of the file passed to `wsl`
    wsl_script=/mnt${PROJECT_DIR}/scripts/build.sh
    win_script=$PROJECT_DIR/scripts/.build.bat
    echo "@echo off & wsl $wsl_script %*" > $win_script
    $win_script $*
    exit 0
fi

set +e # Ignore if the source fails
source ~/.profile # Useful when being called by WSL
set -e # Exit on error
source $PROJECT_DIR/scripts/script-config.sh

# Check if exactly one argument was provided
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one app name as argument"
    exit 1
fi

# Strip 'apps/' prefix if present
if [[ "$1" == apps/* ]]; then
    set -- "${1#apps/}"
fi

# Check if app directory exists
if [ ! -d "$PROJECT_DIR/apps/$1" ]; then
    echo "Error: App directory '$1' not found in apps/"
    exit 1
fi

export BOARD=`cat $PROJECT_DIR/apps/$1/BOARD`

APP_NAME=$1
mkdir -p $ZEPHYR_WORKSPACE/applications

cd $ZEPHYR_WORKSPACE
source .venv/bin/activate
rsync -a --delete $PROJECT_DIR/apps/ $ZEPHYR_WORKSPACE/applications/

west build -p auto -s $ZEPHYR_WORKSPACE/applications/$APP_NAME

cd $ZEPHYR_WORKSPACE/build/zephyr
hss-payload-generator -c $PROJECT_DIR/apps/$APP_NAME/image-conf.yaml zephyr.img
mkdir -p $PROJECT_DIR/build
rsync -a $ZEPHYR_WORKSPACE/build/zephyr/zephyr.* $PROJECT_DIR/build
echo "Build complete"
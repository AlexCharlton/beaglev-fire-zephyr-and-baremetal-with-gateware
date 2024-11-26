#!/bin/bash

set -e # Exit on error

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..

# Check if running in MinGW/MSYS
if [[ "$(uname -s)" == *"MINGW"* ]]; then
    # If so, create a batch file that will run the script in WSL
    # Why the batch file? Otherwise, MSYS will try rewrite the directory of the file passed to `wsl`
    wsl_script=/mnt${PROJECT_DIR}/scripts/build-baremetal-rust.sh
    win_script=$PROJECT_DIR/scripts/.build-baremetal-rust.bat
    echo "@echo off & wsl $wsl_script %*" > $win_script
    $win_script $*
    exit 0
fi

set +e # Ignore if the source fails
source ~/.profile # Useful when being called by WSL
set -e # Exit on error

mkdir -p ~/src/baremetal/

rsync -a --delete --exclude 'build' --exclude 'target' $PROJECT_DIR/baremetal/ $HOME/src/baremetal/

cd $HOME/src/baremetal/hello-rust

## Build using makefile
# rm build.rs
# make
## End build

## OR

## Build using cargo build.rs script
## Does not link nano/nosys specs
cargo build --release
cp target/riscv64gc-unknown-none-elf/release/hello-rust build/hello-rust.elf
## End build

hss-payload-generator -c image-conf.yaml build/application.img
rsync -a --delete --exclude 'mpfs-platform' $HOME/src/baremetal/hello-rust/build/ $PROJECT_DIR/baremetal-build/
echo "Build complete"

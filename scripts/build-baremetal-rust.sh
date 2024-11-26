#!/bin/bash

set -e # Exit on error

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

cd $PROJECT_DIR/baremetal/hello-rust
cargo build --release
mkdir -p build
cp target/riscv64gc-unknown-none-elf/release/hello-rust build/hello-rust.elf
hss-payload-generator -c image-conf.yaml build/application.img
cp build/* $PROJECT_DIR/baremetal-build/

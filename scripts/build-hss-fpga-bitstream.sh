#! /bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

cd $PROJECT_DIR/gateware
source ./setup-microchip-tools.sh
python3 build-bitstream.py blinky.yaml
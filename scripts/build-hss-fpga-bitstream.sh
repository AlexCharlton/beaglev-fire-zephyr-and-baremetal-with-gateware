#! /bin/bash

set -e

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

cd $PROJECT_DIR/gateware
python3 build-bitstream.py $PROJECT_DIR/$GATEWARE_CONFIG_FILE

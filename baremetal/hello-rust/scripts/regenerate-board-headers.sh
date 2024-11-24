#! /bin/bash

set -e

# This directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd $SCRIPT_DIR/..
python src/platform/soc_config_generator/mpfs_configuration_generator.py src/boards/beaglev-fire/fpga_design/design_description/ src/boards/beaglev-fire

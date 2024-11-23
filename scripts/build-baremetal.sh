#! /bin/bash

set -e

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

cd $PROJECT_DIR/baremetal/mpfs-timer-example
make $*

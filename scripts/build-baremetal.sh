#! /bin/bash

set -ex

PROJECT_DIR=$(dirname "$(readlink -f "$0")")/..
source $PROJECT_DIR/scripts/script-config.sh

# Check if exactly one argument was provided
if [ "$#" -ne 1 ]; then
    echo "Error: Please provide exactly one project name as argument"
    exit 1
fi

# Strip 'baremetal/' prefix if present
if [[ "$1" == baremetal/* ]]; then
    set -- "${1#baremetal/}"
fi

# Check if app directory exists
if [ ! -d "$PROJECT_DIR/baremetal/$1" ]; then
    echo "Error: Project directory '$1' not found in baremetal/"
    exit 1
fi

APP_NAME=$1

cd $PROJECT_DIR/baremetal/$APP_NAME
make

#/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/..

dd if=$PROJECT_DIR/build/zephyr.img of=/dev/sdd1 bs=4M status=progress oflag=sync
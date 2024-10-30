#/bin/bash

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

$SCRIPT_DIR/build.bat
$SCRIPT_DIR/flash.sh
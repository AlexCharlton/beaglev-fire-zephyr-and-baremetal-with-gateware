## Usage

Building RISCV application:
```
$ ./scripts/connect-tty.sh
# Hit a key to stop boot, then
# >> mmc
# >> usbdmsc

$ ./scripts/build-flash.sh
$ ./scripts/connect-openocd.sh
$ ./scripts/connect-gdb.bat
```

Building FPGA gateware+HSS:
```
$ ./scripts/build-hss-fpga-bitstream.sh
```
It takes serveral minutes to build.
Open FPExpress, open `gateware/bitstream/FlashProExpress/BLINKY_<HASH>.job`, run "Program".


## Requirements
On Windows/Mingw64:
- Install Libero, SoftConsole

On Linux:
- Install Zephyr + SDK: https://docs.zephyrproject.org/latest/develop/getting_started/index.html
- Install HSS Payload Generator: https://git.beagleboard.org/beaglev-fire/hart-software-services/-/tree/main-beaglev-fire/tools/hss-payload-generator

## TODO
- Pull out variables form scripts into a single file
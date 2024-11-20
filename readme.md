## Usage

Building RISCV application:
```sh
$ ./scripts/build.bat hello-smp
```

Programming the image:
```sh
$ flasher COM5 build/zephyr.img
```
CTRL-Y to enter FLASH mode, then reset to program the image.

Building FPGA gateware+HSS:
```
$ ./scripts/build-hss-fpga-bitstream.sh
```
It takes serveral minutes to build.
Open FPExpress, open `gateware/bitstream/FlashProExpress/BLINKY_<HASH>.job`, run "Program".

### Configuring HSS
```sh
$ cd gateware/sources/HSS
$ make config
...
$ cp .config ../../hss.def_config
```

## Requirements
Cargo, to install flasher:
```sh
$ cd flasher
$ cargo install --path .
```

On Windows/Mingw64:
- Install Libero, SoftConsole

On Linux:
- Install Zephyr + SDK: https://docs.zephyrproject.org/latest/develop/getting_started/index.html
- Install HSS Payload Generator: https://git.beagleboard.org/beaglev-fire/hart-software-services/-/tree/main-beaglev-fire/tools/hss-payload-generator

## TODO
- Pull out variables form scripts into a single file
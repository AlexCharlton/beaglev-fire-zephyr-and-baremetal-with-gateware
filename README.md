# BeagleV Fire Zephyr/Baremetal (C and Rust) + Gateware + HSS

Template for developing Zephyr or baremetal applications on the BeagleV Fire using C or Rust. Only tested on Windows, but should work on anything supported by the Microchip tools (Libero/SoftConsole).

When developing on Windows, it's assumed you're using MSYS2. Zephyr should be installed in WSL, since it apparently does not work particularly well on Windows. The build script will automatically run itself in WSL.

Gateware programming depends on a FlashPro 5/6, for now.

## Requirements
Cargo, to install flasher:
```sh
$ cd flasher
$ cargo install --path .
```

Install [Libero](https://www.microchip.com/en-us/products/fpgas-and-plds/fpga-and-soc-design-tools/fpga/libero-software-later-versions) and [SoftConsole](https://www.microchip.com/en-us/products/fpgas-and-plds/fpga-and-soc-design-tools/soc-fpga/softconsole), for building the FPGA bitstream. Libero requires a license file. Follow the instructions [here](https://ww1.microchip.com/downloads/aemdocuments/documents/fpga/core-docs/Libero/12_4_0/Tool/Libero_Installation_Licensing_Setup_User_Guide_V34.pdf) to install it.

Python3 required for the gateware builder. Install Python libraries:
```sh
$ pip3 install gitpython
$ pip3 install pyyaml
$ pip3 install requests
```

On *nix:
- Install Zephyr + SDK: https://docs.zephyrproject.org/latest/develop/getting_started/index.html
- Install HSS Payload Generator: https://git.beagleboard.org/beaglev-fire/hart-software-services/-/tree/main-beaglev-fire/tools/hss-payload-generator

Configure the environment variables in `scripts/script-config.sh`

## Usage
### Programming a Zephyr application
Building Zephyr application:
```sh
$ ./scripts/build.sh apps/hello-smp
```

With a serial cable connected (I use [this one](https://www.adafruit.com/product/954)), use flasher to program the image:
```sh
$ flasher [your-serial-port] build/zephyr.img
$ # eg. flasher COM5 build/zephyr.img
```

CTRL-Y enters FLASH mode, then reset the board to program the image.

flasher acts as a serial terminal, so it's generally useful to keep open to see the output/logs of the application. CTRL-T to exit.

flasher works by interrupting the HSS bootloader to enter its console, then executes the `mmc` and `usbdmsc` commands to mount the eMMC as a USB drive. It detects newly mounted drives, and writes the given image to it, before unmounting and rebooting the device.

### Programming a baremetal application
The C example uses the RISC-V toolchain from SoftConsole and the Microchip [platform](https://github.com/polarfire-soc/platform).
```sh
$ ./scripts/build-baremetal.sh
$ flasher [your-serial-port] baremetal/mpfs-timer-example/build/application.img
```

The Rust example uses a patched version of the [platform](https://github.com/AlexCharlton/platform).

```sh
$ ./scripts/build-baremetal-rust.sh
$ flasher [your-serial-port] baremetal-build/application.img
```

### GDB debugging
With a JTAG debugger (FlashPro) connected, run:
```sh
$ ./scripts/connect-openocd.sh
```

Then in another terminal, run:
```sh
$ ./scripts/connect-gdb.sh
```

`scripts/init.gdb` can be modified to suit your needs.

### Programming FPGA gateware + HSS
Run the `apps/spi-erase` app (built per the instructions above) to clear the SPI flash before programming the image for the first time. Otherwise, your changes will be overwritten by the [golden image](https://ww1.microchip.com/downloads/aemDocuments/documents/FPGA/ProductDocuments/UserGuides/PolarFire_FPGA_and_PolarFire_SoC_FPGA_Programming_User_Guide_VB.pdf) that is programmed into the BeagleV Fire. **This only needs to be done once.**

Build the FPGA + HSS bitstream:
```sh
$ ./scripts/build-hss-fpga-bitstream.sh
```
It takes serveral minutes to build.

Open FPExpress, open `gateware/bitstream/FlashProExpress/BLINKY_<HASH>.job`, run "Program". When it's done, the board will reboot.

### Configuring HSS
```sh
$ cd gateware/sources/HSS
$ make config
...
$ cp .config ../../hss.def_config
```
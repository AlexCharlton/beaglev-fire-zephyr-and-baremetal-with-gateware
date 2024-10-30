## Usage

```
$ ./scripts/connect-tty.sh
# Hit a key to stop boot, then
# >> mmc
# >> usbdmsc

$ ./scripts/build-flash.sh
$ ./scripts/connect-openocd.sh
$ ./scripts/connect-gdb.bat
```

## Requirements
On Windows/Mingw64:
- Install Libero, SoftConsole
```
pacman -S tio
```

On Linux:
- Install Zephyr + SDK: https://docs.zephyrproject.org/latest/develop/getting_started/index.html
- Install HSS Payload Generator: https://git.beagleboard.org/beaglev-fire/hart-software-services/-/tree/main-beaglev-fire/tools/hss-payload-generator

## TODO
- Steal the logic from https://github.com/polarfire-soc/zephyr-applications/blob/main/scripts/flash_payload.py
- Pull out variables form scripts into a single file
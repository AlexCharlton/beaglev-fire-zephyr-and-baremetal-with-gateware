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
It takes serveral minutes to build. At the end you'll see some logs like
```
Opened 'C:\programming\beaglev\gateware\work\libero\designer\MIDI_CTRL_2A2BBD5E9DF2F5EE1861\MIDI_CTRL_2A2BBD5E9DF2F5EE1861_fp\MIDI_CTRL_2A2BBD5E9DF2F5EE1861.pro'
PDB file 'C:\programming\beaglev\gateware\work\libero\designer\MIDI_CTRL_2A2BBD5E9DF2F5EE1861\MIDI_CTRL_2A2BBD5E9DF2F5EE1861.pdb' has been loaded successfully.
```
Open FPExpress, open the project, load the pdb file.
To determine: Can we just use the pdb file and create a new project with it?


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
- Apply HSS .config
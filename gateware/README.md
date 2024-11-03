# BeagleV Fire Gateware Builder

## Introduction
The BeagleV Fire gateware builder is a Python script that builds both the PolarFire SoC HSS bootloader and Libero FPGA project into a single programming bitstream. It uses a list of repositories/branches specifying the configuration of the BeagleV Fire to build.


## Prerequisites
### Python libraries
The following Python libraries are used:
- GitPython
- PyYAML
- requests

```
pip3 install gitpython
pip3 install pyyaml
pip3 install requests
```

### Microchip Tools
The SoftConsole and Libero tools from Microchip are required by the bitstream builder.

The following environment variables are required for the bitstream builder to use the Microchip tools:
- SC_INSTALL_DIR
- FPGENPROG
- LIBERO_INSTALL_DIR
- LM_LICENSE_FILE

To do so, run `source ./setup-microchip-tools.sh` in the terminal.

## Usage

```
python3 build-bitstream.py <YAML Configuration File>
```

## Microchip bitstream-builder
The BeagleV-Fire gateware builder is derived from [Microchip's bitstream-builder ](https://github.com/polarfire-soc/icicle-kit-minimal-bring-up-design-bitstream-builder). We recommend that you use either of these scripts as a starting point for your own PolarFire SoC FPGA designs as opposed to using Libero in isolation.
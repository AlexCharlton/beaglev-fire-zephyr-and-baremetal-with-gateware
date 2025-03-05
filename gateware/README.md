# BeagleV Fire Gateware Builder
Adapted from https://git.beagleboard.org/beaglev-fire/gateware, which in turn is adapted from [Microchip's bitstream-builder](https://github.com/polarfire-soc/icicle-kit-minimal-bring-up-design-bitstream-builder).

In particular, we are not using the Beagle fork of HSS, but the [main branch](https://github.com/polarfire-soc/hart-software-services) which now has BeagleV support and also boots more reliably.

The BeagleV Fire gateware builder is a Python script that builds both the PolarFire SoC HSS bootloader and Libero FPGA project into a single programming bitstream. It uses a list of repositories/branches specifying the configuration of the BeagleV Fire to build. We are using `default.yaml` as our main configuration. See [this tutorial](https://docs.beagle.cc/boards/beaglev/fire/demos-and-tutorials/gateware/customize-cape-gateware-verilog.html) for a general guide on how to customize the gateware.
# Baremetal Rust example
Hello world, from Rust using a patched PolarFire platform: https://github.com/AlexCharlton/platform

This will only build on a more recent version of the riscv toolchain than what's shipped with SoftConsole.

There are two ways to build this: using the Makefile, or using the Rust build script. See `scripts/build-baremetal-rust.wsl.sh` for the two methods.

`scripts/build-baremetal-rust.sh` is now the default, using the Rust build script, since it runs on Windows without WSL.

### Dev
The Makefile requires a more recent version of the RISC-V toolchain. I couldn't get a working version of the toolchain on Windows, so the build script assumes you have a WSL [installation](https://github.com/riscv-collab/riscv-gnu-toolchain) available (see above for installation instructions).

Installing a newer version of the RISC-V toolchain:
```sh
$ git clone https://github.com/riscv-collab/riscv-gnu-toolchain
$ cd riscv-gnu-toolchain
$ ./configure --prefix=/opt/riscv --with-arch=rv64gc --with-abi=lp64d
$ make
```

And add `/opt/riscv/bin` to your PATH. Then:
```sh
$ ./scripts/build-baremetal-rust.wsl.sh
$ flasher [your-serial-port] baremetal-build/application.img
```

#### cargo check

Get cargo to check using the correct target:
```sh
$ cargo check --target riscv64gc-unknown-none-elf
```

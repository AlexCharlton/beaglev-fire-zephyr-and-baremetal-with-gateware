# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

set(BOARD beaglev_fire/polarfire/u54)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(spi_erase)

target_sources(app PRIVATE src/main.c)

# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

set(BOARD beaglev_fire/polarfire/u54/smp)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(hello_smp)

target_sources(app PRIVATE src/main.c)

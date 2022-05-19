#!/bin/bash
# This script is used to build the code in the build folder
# Just for me to rembember what to write
cd build
cmake .. -DPROJ="asm" -DTOOLCHAIN="/home/lasagna/Documents/PlatformIO/RISCV-ASM/kendryte-toolchain/bin"
make -B
cd ..

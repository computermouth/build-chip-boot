#!/bin/bash

set -x

rm -rf chip-u-boot
rm -rf chip-boot

mkdir chip-boot

git clone https://github.com/nextthingco/chip-u-boot
pushd chip-u-boot

git checkout nextthing/2016.01/next

mv ../CHIP_defconfig configs/CHIP_defconfig

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- CHIP_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j8 

cp spl/sunxi-spl.bin ../chip-boot/
cp spl/sunxi-spl-with-ecc.bin ../chip-boot/

cp u-boot-dtb.bin ../

popd

dd if=u-boot-dtb.bin of=padded-u-boot-dtb.bin bs=4M conv=sync

UBOOT_SIZE=`wc -c padded-u-boot-dtb.bin | awk '{printf $1}' | xargs printf "0x%08x"`
dd if=/dev/urandom of=padded-u-boot-dtb.bin seek=$((UBOOT_SIZE / 0x4000)) bs=16k count=$(((0x400000 - UBOOT_SIZE) / 0x4000))

cp padded-u-boot-dtb.bin chip-boot/

cp u-boot-dtb.bin chip-boot/

rm *.bin

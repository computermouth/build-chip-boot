#!/bin/bash

set -ex

PADDED_UBOOT_SIZE=0x400000

UBOOT_MEM_ADDR=0x4a000000
SPL_MEM_ADDR=0x43000000
#UBI_MEM_ADDR=0x4b000000

prepare_uboot_script() {
    echo "nand erase 0x0 0x200000000" > "${UBOOT_SCRIPT_SRC}"
    
    echo "echo nand write.raw.noverify $SPL_MEM_ADDR 0x0 $PADDED_SPL_SIZE" >> "${UBOOT_SCRIPT_SRC}"
    echo "nand write.raw.noverify $SPL_MEM_ADDR 0x0 $PADDED_SPL_SIZE" >> "${UBOOT_SCRIPT_SRC}"
    echo "echo nand write.raw.noverify $SPL_MEM_ADDR 0x400000 $PADDED_SPL_SIZE" >> "${UBOOT_SCRIPT_SRC}"
    echo "nand write.raw.noverify $SPL_MEM_ADDR 0x400000 $PADDED_SPL_SIZE" >> "${UBOOT_SCRIPT_SRC}"
    
    echo "nand write $UBOOT_MEM_ADDR 0x800000 $PADDED_UBOOT_SIZE" >> "${UBOOT_SCRIPT_SRC}"
#    echo "setenv bootargs root=ubi0:rootfs rootfstype=ubifs rw earlyprintk ubi.mtd=4" >> "${UBOOT_SCRIPT_SRC}"
#    echo "setenv bootcmd 'gpio set PB2; if test -n \${fel_booted} && test -n \${scriptaddr}; then echo '(FEL boot)'; source \${scriptaddr}; fi; mtdparts; ubi part UBI; ubifsmount ubi0:rootfs; ubifsload \$fdt_addr_r /boot/sun5i-r8-chip.dtb; ubifsload \$kernel_addr_r /boot/zImage; bootz \$kernel_addr_r - \$fdt_addr_r'" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv bootargs" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv bootcmd 'gpio set PB2; if test -n \${fel_booted} && test -n \${scriptaddr}; then echo '(FEL boot)'; source \${scriptaddr}; fi;'" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv fel_booted 0" >> "${UBOOT_SCRIPT_SRC}"
    
    echo "echo Enabling Splash" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv stdout serial" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv stderr serial" >> "${UBOOT_SCRIPT_SRC}"
    echo "setenv splashpos m,m" >> "${UBOOT_SCRIPT_SRC}"
    
    echo "echo Configuring Video Mode"
    echo "setenv video-mode sunxi:640x480-24@60,monitor=composite-ntsc,overscan_x=40,overscan_y=20" >> "${UBOOT_SCRIPT_SRC}"
    
    echo "saveenv" >> "${UBOOT_SCRIPT_SRC}"
    
#  if [[ "${METHOD}" == "fel" ]]; then
#	  echo "nand write.slc-mode.trimffs $UBI_MEM_ADDR 0x1000000 $UBI_SIZE" >> "${UBOOT_SCRIPT_SRC}"
#	  echo "mw \${scriptaddr} 0x0" >> "${UBOOT_SCRIPT_SRC}"
#  else
#    echo "echo going to fastboot mode" >>"${UBOOT_SCRIPT_SRC}"
#    echo "fastboot 0" >>"${UBOOT_SCRIPT_SRC}"
#  fi
    
    echo "echo " >>"${UBOOT_SCRIPT_SRC}"
    echo "echo *****************[ FLASHING DONE ]*****************" >>"${UBOOT_SCRIPT_SRC}"
    echo "echo " >>"${UBOOT_SCRIPT_SRC}"
    echo "while true; do; sleep 1 && i2c mw 0x34 0x93 0x00 && sleep 1 && i2c mw 0x34 0x93 0x01; done;" >>"${UBOOT_SCRIPT_SRC}"

    mkimage -A arm -T script -C none -n "flash CHIP" -d "${UBOOT_SCRIPT_SRC}" "${UBOOT_SCRIPT}"
}

PADDED_SPL_SIZE=$( echo "196" | awk '{printf $1}' | xargs printf "0x%08x")
#UBI_SIZE=$(wc -c $PWD/build-desk/desktop-rootfs.ubi.img | awk '{printf $1}' | xargs printf "0x%08x")
UBOOT_SCRIPT_SRC="$PWD/chip-boot/uboot-fel.cmds"
UBOOT_SCRIPT="$PWD/chip-boot/uboot-fel.scr"

prepare_uboot_script

mkdir -p chip-boot/images
cp chip-boot/padded-u-boot-dtb.bin     chip-boot/images/padded-u-boot
cp chip-boot/sunxi-spl.bin             chip-boot/images/
cp chip-boot/sunxi-spl-with-ecc.bin    chip-boot/images/
cp chip-boot/uboot-fel.scr             chip-boot/images/uboot.scr
cp chip-boot/u-boot-dtb.bin            chip-boot/images/

#!/bin/bash

FEL=fel
SPL="img-chip-boot/images/sunxi-spl.bin"
SPL_MEM_ADDR=0x43000000
PADDED_SPL="img-chip-boot/images/sunxi-spl-with-ecc.bin"
UBOOT_MEM_ADDR=0x4a000000
PADDED_UBOOT="img-chip-boot/images/padded-u-boot"
UBOOT_SCRIPT_MEM_ADDR=0x43100000
UBOOT_SCRIPT="img-chip-boot/images/uboot.scr"

${FEL} spl "${SPL}"

sleep 1 # wait for DRAM initialization to complete

echo == upload spl ==
${FEL} write $SPL_MEM_ADDR "${PADDED_SPL}" || ( echo "ERROR: could not write ${PADDED_SPL}" && exit $? )

echo == upload u-boot ==
${FEL} write $UBOOT_MEM_ADDR "${PADDED_UBOOT}" || ( echo "ERROR: could not write ${PADDED_UBOOT}" && exit $? )

echo == upload u-boot script ==
${FEL} write $UBOOT_SCRIPT_MEM_ADDR "${UBOOT_SCRIPT}" || ( echo "ERROR: could not write ${UBOOT_SCRIPT}" && exit $? )

echo == execute the main u-boot binary ==
${FEL} exe $UBOOT_MEM_ADDR

sleep 15s
echo -e "\n\nFLASH COMPLETE.\n\n"

echo "   #  #  #"
echo "  #########"
echo "###       ###"
echo "  # {#}   #"
echo "###  '\######"
echo "  #       #"
echo "###       ###"
echo "  ########"
echo "   #  #  #"

echo -e "\n\nCHIP is ready to roll!\n\n"

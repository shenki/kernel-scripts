#!/bin/bash

set -e

OBJ=palmetto-obj
CONFIG=evb-ast2400_defconfig
IMG="$OBJ/test.img"
MACHINE=ast2400-palmetto
QEMU_MACHINE=palmetto-bmc

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -s $CONFIG
make CROSS_COMPILE="ccache arm-linux-gnueabi-" -j8 O="$OBJ" DEVICE_TREE=$MACHINE -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$IMG"
truncate -s 32M "$IMG"

echo "$CONFIG build complete"
echo "qemu-system-arm -M $QEMU_MACHINE -nographic -drive file=$IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/"

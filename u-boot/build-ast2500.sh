#!/bin/bash

set -e

OBJ=ast2500-obj
CONFIG=evb-ast2500_defconfig
IMG="$OBJ/test.img"
QEMU_MACHINE=ast2500-evb

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -j8 -s $CONFIG
CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm make -j8 O="$OBJ"  -j8 DEVICE_TREE=ast2500-evb -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$OBJ/test.img"
truncate -s 32M "$OBJ/test.img"

echo "$CONFIG build complete"
echo "qemu-system-arm -M $QEMU_MACHINE -nographic -drive file=$IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/"

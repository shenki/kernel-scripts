#!/bin/bash

set -e

OBJ=ast2600-obj
CONFIG=evb-ast2600_defconfig
IMG="$OBJ/test.img"
MACHINE=ast2600-evb

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -j8 -s $CONFIG
CROSS_COMPILE="ccache arm-linux-gnueabi-" ARCH=arm make -j8 O="$OBJ"  -j8 DEVICE_TREE=$MACHINE -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$OBJ/test.img"
truncate -s 64M "$OBJ/test.img"

echo "$CONFIG build complete"
echo "qemu-system-arm -M $MACHINE -nographic -drive file=$IMG,if=mtd,format=raw"

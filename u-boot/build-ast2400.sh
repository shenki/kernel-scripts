#!/bin/bash

set -ex

OBJ=ast2400-obj
CONFIG=evb-ast2400_defconfig
: ${DTB:=ast2400-evb}
IMG="$OBJ/test.img"
QEMU_MACHINE=palmetto-bmc

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -j8 -s $CONFIG
CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm make -j8 O="$OBJ"  -j8 DEVICE_TREE="$DTB" -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$IMG"
truncate -s 32M "$IMG"

echo "$CONFIG build complete"
echo "qemu-system-arm -M $QEMU_MACHINE -nographic -drive file=$IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/"

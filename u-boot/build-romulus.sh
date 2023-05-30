#!/bin/bash

set -e

OBJ=romulus-obj
CONFIG=evb-ast2500_defconfig
IMG="$OBJ/test.img"
QEMU_MACHINE=romulus-bmc

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -s $CONFIG
CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm make -j8 O="$OBJ" DEVICE_TREE=ast2500-romulus -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$IMG"
truncate -s 32M "$IMG"

echo "$CONFIG build complete"
echo "qemu-system-arm -M $QEMU_MACHINE -nographic -drive file=$IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/"

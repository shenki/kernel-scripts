#!/bin/bash

set -e

OBJ=ast2600-obj
CONFIG=evb-ast2600_defconfig
TEST_IMG="$OBJ/test.img"
MACHINE=ast2600-evb
KERNEL_FIT=/srv/tftp/evb6

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -j8 -s $CONFIG
CROSS_COMPILE="ccache arm-linux-gnueabi-" ARCH=arm make -j8 O="$OBJ"  -j8 DEVICE_TREE=$MACHINE -s
size "$OBJ/u-boot"

cp "$OBJ/u-boot.bin" "$TEST_IMG"
truncate -s 64M "$TEST_IMG"
[ -f "$KERNEL_FIT" ] && dd status=none if="$KERNEL_FIT" of="$TEST_IMG" conv=notrunc seek=1 bs=1M

echo "$CONFIG build complete"
echo "qemu-system-arm -M $MACHINE -nographic -drive file=$TEST_IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/"

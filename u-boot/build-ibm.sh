#!/bin/bash
# This is a series of hacks to build a u-boot image
# Run it from an OpenBMC u-boot tree
# https://github.com/openbmc/u-boot

set -e

# Configure the following for your machine
#
# KEYS: 	Location of signing keys. This uses the ones from the OpenBMC Yocto tree
#
# KERNEL_FIT: 	Location of kernel FIT to be embedded in the image. If building
# 		for hardware omit this as it will come from the filesystem, but
# 		if testing the script will load this image from the raw eMMC device
#
# QEMU_SYSTEM_ARM: Location of qemu binary

KEYS=$HOME/dev/openbmc/openbmc/meta-aspeed/recipes-kernel/linux/linux-aspeed/
KERNEL_FIT=/srv/tftp/rain-sec
QEMU_SYSTEM_ARM=$HOME/dev/qemu/cedric/build/qemu-system-arm

# Modify these for building for a different platform
# Note that this script assumes a Qemu capable of eMMC boot, such as with
# Cédric's Aspeed tree https://github.com/legoater/qemu/
MACHINE=ast2600-p10bmc
OBJ=ibm-obj
TEST_IMG=$OBJ/test.img
CONFIG=ast2600_openbmc_spl_emmc_defconfig

echo Configuring u-boot for $CONFIG
set -x
make O="$OBJ" -s clean
make O="$OBJ" -s "$CONFIG"
echo CONFIG_BOARD_EARLY_INIT_F=n >> "$OBJ/.config"
echo CONFIG_TARGET_AST2600_IBM=y >> "$OBJ/.config"
{ set +x; } 2>/dev/null

if [ -f "$KERNEL_FIT" ]; then
	KERNEL_FIT_SIZE=$(ls --block-size=512 -s "$KERNEL_FIT" | cut -d' ' -f 1)
	KERNEL_FIT_SIZE=$(printf %x $KERNEL_FIT_SIZE)
	set -x
	echo CONFIG_BOOTCOMMAND=\"mmc read 0x83000000 0 "$KERNEL_FIT_SIZE" \&\& bootm\" >> "$OBJ/.config"
	echo CONFIG_USE_DEFAULT_ENV_FILE=n >> "$OBJ/.config"
	{ set +x; } 2>/dev/null
fi

set -x
make CROSS_COMPILE="ccache arm-linux-gnueabi-" O=$OBJ  -j8 DEVICE_TREE=$MACHINE -s
{ set +x; } 2>/dev/null

echo
size "$OBJ/u-boot" "$OBJ/spl/u-boot-spl"

cat > $OBJ/u-boot.its << EOF
/dts-v1/;
/ {
    description = "U-Bueaty (IBM P10)";
    images {
        u-boot { description = "U-Boot image"; data = /incbin/("u-boot-nodtb.bin");
            type = "standalone"; os = "u-boot"; arch = "arm"; compression = "none";
            load = <0x80001000>; entry = <0x80001000>;
            hash { algo = "sha256"; };
        };
        fdt { description = "U-Boot FDT"; data = /incbin/("u-boot.dtb");
            type = "flat_dt"; arch = "arm"; compression = "none";
            hash { algo = "sha256"; };
        };
    };
    configurations {
        default = "conf";
	conf { description = "u-boot with fdt"; loadables = "u-boot"; fdt = "fdt"; };
    };
};
EOF

echo
echo "Generating signed u-boot device tree for SPL"
set -x
"$OBJ/tools/mkimage" -f "$OBJ/u-boot.its" -r -E -k "$KEYS" -K "$OBJ/u-boot.dtb" "$OBJ/u-boot-signed.img" > /dev/null
{ set +x; } 2>/dev/null

echo
echo "Rebuilding with signature in device tree"
set -x
make O="$OBJ" -s -j8 DEVICE_TREE=$MACHINE EXT_DTB="$PWD/$OBJ/u-boot.dtb" CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
{ set +x; } 2>/dev/null

echo
echo "Generating signed FIT Image"
set -x
$OBJ/tools/mkimage -f "$OBJ/u-boot.its" -r -E -k "$KEYS" "$OBJ/u-boot-signed.img" > /dev/null
{ set +x; } 2>/dev/null

echo
echo "Creating image $TEST_IMG"
[ ! -f "$TEST_IMG" ] && dd if=/dev/zero of=$TEST_IMG count=1 bs=16M
dd status=none if="$OBJ/spl/u-boot-spl.bin" of="$TEST_IMG" conv=notrunc
dd status=none if="$OBJ/u-boot-signed.img" of="$TEST_IMG" conv=notrunc seek=64 bs=1024
[ -f "$KERNEL_FIT" ] && dd status=none if="$KERNEL_FIT" of="$test_img" conv=notrunc seek=2 bs=1m

echo
echo "$CONFIG build complete"
echo
echo "$QEMU_SYSTEM_ARM" -M rainier-bmc -nographic -drive file=$TEST_IMG,if=sd,format=raw,index=2 -nic user,tftp=/srv/tftp/

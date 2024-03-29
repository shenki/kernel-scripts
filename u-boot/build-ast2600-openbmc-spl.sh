#!/bin/bash
# Suitable for building upstream u-boot for ast2600

set -e

OBJ=ast2600-obj
CONFIG=ast2600_openbmc_spl_defconfig
IMG="$OBJ/test.img"
MACHINE=ast2600-evb
KEYS=$HOME/dev/openbmc/openbmc/meta-aspeed/recipes-kernel/linux/linux-aspeed/
KERNEL_FIT=/srv/tftp/rain-sec

set -x
#make O="$OBJ" -s clean
make O="$OBJ" -s $CONFIG
make O="$OBJ" -s -j8 DEVICE_TREE=$MACHINE CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
{ set +x; } 2>/dev/null

size "$OBJ/u-boot" "$OBJ/spl/u-boot-spl"

cat > u-boot.its << EOF
/dts-v1/;
/ {
    description = "U-Bueaty";
    images {
        u-boot { description = "U-Boot image"; data = /incbin/("ast2600-obj/u-boot-nodtb.bin");
            type = "standalone"; os = "u-boot"; arch = "arm"; compression = "none";
            load = <0x80001000>; entry = <0x80001000>;
            hash { algo = "sha256"; };
        };
        fdt { description = "U-Boot FDT"; data = /incbin/("ast2600-obj/u-boot.dtb");
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

echo "Generating FIT Image"
set -x
"$OBJ/tools/mkimage" -f u-boot.its -E -k $KEYS -K $OBJ/spl/u-boot-spl.dtb "$OBJ/u-boot.itb" > /dev/null
{ set +x; } 2>/dev/null

echo "+ Rebuilding with signature in device tree"
set -x
make O="$OBJ" -s -j8 DEVICE_TREE=$MACHINE EXT_DTB=$PWD/$OBJ/spl/u-boot-spl.dtb CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
{ set +x; } 2>/dev/null

echo "Creating image $OBJ/test.img"
set -x
cp "$OBJ/spl/u-boot-spl.bin" "$OBJ/test.img"
truncate -s 64M "$OBJ/test.img"
dd status=none if="$OBJ/u-boot.itb" of="$OBJ/test.img" conv=notrunc seek=64 bs=1024
dd status=none if="$KERNEL_FIT" of="$OBJ/test.img" conv=notrunc seek=1024 bs=1024
{ set +x; } 2>/dev/null

echo
echo "$CONFIG build complete"
echo "qemu-system-arm -M $MACHINE -nographic -drive file=$IMG,if=mtd,format=raw"

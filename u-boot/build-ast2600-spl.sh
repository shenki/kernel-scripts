#!/bin/bash
# Suitable for building upstream u-boot for ast2600

set -e

OBJ=ast2600-obj
CONFIG=evb-ast2600_defconfig
IMG="$OBJ/test.img"
MACHINE=ast2600-evb

set -x
#make O="$OBJ" -s clean
#make O="$OBJ" -s $CONFIG
make O="$OBJ" -s -j8 DEVICE_TREE=$MACHINE CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm
{ set +x; } 2>/dev/null

size "$OBJ/u-boot"
size "$OBJ/spl/u-boot-spl" | tail -n1

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

"$OBJ/tools/mkimage" -f u-boot.its -E "$OBJ/u-boot.itb" > /dev/null

cp "$OBJ/spl/u-boot-spl.bin" "$OBJ/test.img"
truncate -s 64M "$OBJ/test.img"
#dd status=none if="$OBJ/u-boot.itb" of="$OBJ/test.img" conv=notrunc seek=64 bs=1024
dd status=none if="$OBJ/u-boot.img" of="$OBJ/test.img" conv=notrunc seek=64 bs=1024

echo
echo "$CONFIG build complete"
echo "qemu-system-arm -M $MACHINE -nographic -drive file=$IMG,if=mtd,format=raw"

set -e

OBJ=ast2600-obj
CONFIG=ast2600_openbmc_spl_defconfig
MACHINE=ast2600-evb
TEST_IMG="$OBJ/test.img"

set -x

make -j8 O="$OBJ" -s clean
make -j8 O="$OBJ" -s "$CONFIG"
CROSS_COMPILE="ccache arm-linux-gnueabi-" make O="$OBJ" DEVICE_TREE="$MACHINE" -j8 -s
size $OBJ/u-boot $OBJ/spl/u-boot-spl

cat > $OBJ/u-boot.its << EOF
/dts-v1/;
/ {
    description = "U-Bueaty (AST2600 EVB)";
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

#$OBJ/tools/mkimage -f "$OBJ/u-boot.its" -E "$OBJ/u-boot.img" > /dev/null

[ ! -f "$TEST_IMG" ] && dd if=/dev/zero of=test.img count=1 bs=16M
dd status=none if=$OBJ/spl/u-boot-spl.bin of="$TEST_IMG" conv=notrunc
dd status=none if="$OBJ/u-boot.img" of="$TEST_IMG" conv=notrunc seek=64 bs=1024

echo ~/dev/qemu/cedric/build/qemu-system-arm -M ast2600-evb -nographic -drive file=$TEST_IMG,if=mtd,format=raw -nic user,tftp=/srv/tftp/


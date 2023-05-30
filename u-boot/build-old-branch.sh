set -e

make -j8 O=aspeed-g5-dev -s clean
CROSS_COMPILE="ccache arm-linux-gnueabi-" ARCH=arm make -j8 O=aspeed-g5-dev  -j8 -s  ast2600_openbmc_spl_emmc_defconfig
CROSS_COMPILE="ccache arm-linux-gnueabi-" ARCH=arm make -j8 O=aspeed-g5-dev  -j8 -s DEVICE_TREE=ast2600-rainier
size aspeed-g5-dev/spl/u-boot-spl

./aspeed-g5-dev/tools/mkimage -f u-boot.its -r -E -k ~/dev/openbmc/openbmc/meta-aspeed/recipes-kernel/linux/linux-aspeed/ -K aspeed-g5-dev/spl/u-boot-spl.dtb u-boot-signed.img

[ ! -f test.img ] && dd if=/dev/zero of=test.img count=1 bs=16M
dd if=aspeed-g5-dev/spl/u-boot-spl.bin of=test.img conv=notrunc
dd if=u-boot-signed.img of=test.img conv=notrunc seek=64 bs=1024


set -e

OBJ=ast2600-obj
CONFIG=ast2600_openbmc_spl_emmc_defconfig

make -j8 O=$OBJ -s clean
make -j8 O=$OBJ -j8 -s ast2600_openbmc_spl_emmc_defconfig
CROSS_COMPILE="ccache arm-linux-gnueabi-" ARCH=arm make -j8 O=$OBJ  -j8 DEVICE_TREE=ast2600-rainier EXT_DTB=$HOME/dev/kernels/misc/u-boot-p10bmc.dtb -s
size $OBJ/u-boot $OBJ/spl/u-boot-spl

./$OBJ/tools/mkimage -f u-boot.its -r -E -k ~/dev/openbmc/openbmc/meta-aspeed/recipes-kernel/linux/linux-aspeed/ -K $OBJ/spl/u-boot-spl.dtb u-boot-signed.img

[ ! -f test.img ] && dd if=/dev/zero of=test.img count=1 bs=16M
dd if=$OBJ/spl/u-boot-spl.bin of=test.img conv=notrunc
dd if=u-boot-signed.img of=test.img conv=notrunc seek=64 bs=1024

echo ~/dev/qemu/cedric/build/qemu-system-arm -M rainier-bmc -nographic -drive file=test.img,if=sd,format=raw,index=2 -nic user,tftp=/srv/tftp/


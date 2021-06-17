#BUILD=https://builds.tuxbuild.com/1oDtZ1d0lqV9nrXhIzfF6WUDCo9
BUILD=https://builds.tuxbuild.com/1oDtoGMge0cGKE1uoNPpnSSnqwi
IMAGES="zImage dtbs.tar.xz"

G5_DTBS="aspeed-bmc-opp-romulus.dtb aspeed-bmc-opp-witherspoon.dtb"
G6_DTBS="aspeed-bmc-ibm-rainier.dtb aspeed-bmc-opp-tacoma.dtb"
NPCM_DTBS="nuvoton-npcm730-gsj.dtb nuvoton-npcm730-kudo.dtb nuvoton-npcm750-evb.dtb nuvoton-npcm750-runbmc-olympus.dtb"

for image in ${IMAGES}; do
	wget -c ${BUILD}/${image}
done

tar xf dtbs.tar.xz

for dtb in ${NPCM_DTBS}; do
	qemu-system-arm -M npcm750-bmc -nographic -net nic -kernel zImage -dtb "dtbs/${dtb}" -initrd ~/dev/cbl-continuous-integration/images/arm/rootfs.cpio -no-reboot
done

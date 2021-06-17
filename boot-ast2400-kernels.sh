#BUILD=https://builds.tuxbuild.com/1oDtZ1d0lqV9nrXhIzfF6WUDCo9
BUILD=$1
IMAGES="zImage dtbs.tar.xz"

DTBS="aspeed-ast2500-evb.dtb aspeed-bmc-opp-romulus.dtb aspeed-bmc-opp-witherspoon.dtb aspeed-ast2600-evb.dtb aspeed-bmc-ibm-rainier.dtb aspeed-bmc-opp-tacoma.dtb"
MACHINES="ast2500-evb romulus-bmc witherspoon-bmc ast2600-evb rainier-bmc tacoma-bmc"

G4_DTBS="aspeed-bmc-opp-palmetto.dtb"
G5_DTBS="aspeed-bmc-opp-romulus.dtb aspeed-bmc-opp-witherspoon.dtb"
G6_DTBS="aspeed-bmc-ibm-rainier.dtb aspeed-bmc-opp-tacoma.dtb"

QEMU=~/dev/qemu/cedric/build/qemu-system-arm
G4_MACHINE="palmetto-bmc"
G5_MACHINE="romulus-bmc"
G6_MACHINE="ast2600-evb"

set -e

if [ -z "${BUILD}" ]; then
	echo "Pass tuxsuite URL as argument"
	exit -1
fi

echo "Removing ${IMAGES}..."
rm -f ${IMAGES}

for image in ${IMAGES}; do
	echo "Downloading ${BUILD}/${image}"
	wget --quiet -c "${BUILD}/${image}"
done

tar xf dtbs.tar.xz


for dtb in "${G4_DTBS}"; do
	echo "Booting ${dtb} in ${G4_MACHINE}"
	"${QEMU}" -M "${G4_MACHINE}" -nographic -net nic \
		-drive file=/srv/tftp/flash-palmetto,if=mtd,format=raw \
		-kernel zImage -dtb "dtbs/${dtb}" \
		-initrd ~/dev/cbl-continuous-integration/images/arm/rootfs.cpio \
		-append "console=ttyS4,115200n8 quiet" -no-reboot
done

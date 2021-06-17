#!/bin/bash

MMC_IMAGE=mmc.img

WGET_CMD="wget --quiet --show-progress"

BASE_URL="https://jenkins.openbmc.org/view/latest/job/latest-master/label=docker-builder,target=p10bmc/lastSuccessfulBuild/artifact/openbmc/build/tmp/deploy/images/p10bmc/"
UPDATE_FILE="obmc-phosphor-image-p10bmc.ext4.mmc.tar"
MMC_FILE="obmc-phosphor-image-p10bmc.wic.xz"

if [ -f "$UPDATE_FILE" ]; then
	echo "Existing $UPDATE_FILE found. Press r to reuse or ctrl+c to exit"
	while [ 1 ]; do
		read -n 1 -s k <&1
		if [ $k = r ]; then
			echo "Reusing downloaded file"
			break
		else
			echo "Exiting..."
			exit 1
		fi
	done
else
	echo "Fetching update tarball $UPDATE_FILE (~50MB)..."
	$WGET_CMD "${BASE_URL}${UPDATE_FILE}"
fi

if [ -f "$MMC_FILE" ]; then
	echo "Existing $MMC_FILE found. Press r to reuse or ctrl+c to exit"
	while [ 1 ]; do
		read -n 1 -s k <&1
		if [ $k = r ]; then
			echo "Reusing downloaded file"
			break
		else
			echo "Exiting..."
			exit 1
		fi
	done
else
	echo "Fetching mmc image $MMC_FILE (~60MB)..."
	$WGET_CMD "${BASE_URL}${MMC_FILE}"
fi


echo "Extracting boot0 image..."
tar xvf obmc-phosphor-image-p10bmc.ext4.mmc.tar image-u-boot

echo "Decompressing mmc image..."
unxz -k ${MMC_FILE}

echo "Creating image..."
#dd if=/dev/zero of=mmc-bootarea.img count=1 bs=1M
#dd if=u-boot-spl.bin of=mmc-bootarea.img conv=notrunc
#dd if=u-boot.bin of=mmc-bootarea.img conv=notrunc count=64 bs=1K
#cat mmc-bootarea.img mmc-bootarea.img obmc-phosphor-image.wic > ${MMC_IMAGE}
cat image-u-boot image-u-boot ${MMC_FILE%".xz"} > ${MMC_IMAGE}
truncate --size 16G ${MMC_IMAGE}

echo "Image $MMC_IMAGE created. Boot with:"
echo ""
echo "qemu-system-arm -nographic -M rainier-bmc -drive file=mmc.img,if=mmc,index=2,format=raw"
echo ""

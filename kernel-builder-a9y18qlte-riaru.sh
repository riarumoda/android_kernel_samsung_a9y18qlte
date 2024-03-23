#!/bin/bash

# Riaru Kernel Simple Build System
# Here is the dependencies to build the kernel
# Ubuntu/Ubuntu Based OS: apt update && apt upgrade && apt install nano bc bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd sudo make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu python2
# Arch/Arch Based OS: sudo pacman -S bc bison ca-certificates curl flex glibc openssl openssh wget zip zstd make clang aarch64-linux-gnu-gcc arm-none-eabi-gcc archivetools base-devel python

# Logs
echo "Removing previous kernel build logs..."
LOGGER=kernel-logs.txt
REALLOGGER="$(pwd)"/${LOGGER}
rm -rf $REALLOGGER

# Manual clock sync for WSL, look at your /usr/share/zoneinfo/* to see more info
ISTHISWSL=1
CONTINENTS=Asia
LOCATION=Makassar
if [ "$ISTHISWSL" == "1" ]; then
	echo "Asking sudo password for updating the timezone manually..."
	sudo ln -sf /usr/share/zoneinfo/$CONTINENTS/$LOCATION /etc/localtime &>> $REALLOGGER
	sudo hwclock --systohc &>> $REALLOGGER
fi

# DEFCONFIG
DEFCONFIG=a9y18qlte_defconfig

# LineageOS 19.1 Google GCC 4.9
NOTHAVEGCC=1
LOSGCC_DIR="los-gcc"
REALLOSGCC_DIR="$(pwd)"/${LOSGCC_DIR}
if [ "$NOTHAVEGCC" == "1" ]; then
	rm -rf $LOSGCC_DIR
	echo "Cloning Google GCC 4.9 from LienageOS Repository..."
	git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 $LOSGCC_DIR &>> $REALLOGGER
fi
echo "Setting up proper permissions to GCC and export it to PATH..."
sudo chmod 755 -R $REALLOSGCC_DIR &>> $REALLOGGER
export PATH="$REALLOSGCC_DIR/bin:$PATH"

# Variables
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST="$HOSTNAME"
export CROSS_COMPILE=aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

# KernelSU support
KSU=1
if [ "$KSU" == "1" ]; then
	echo "Enabling KernelSU support..."
	rm -rf KernelSU &>> $REALLOGGER
	cd drivers
	rm -rf kernelsu &>> $REALLOGGER
	cd ..
	git clone https://github.com/backslashxx/KernelSU &>> $REALLOGGER
	cd drivers
	ln -sf ../KernelSU/kernel kernelsu &>> $REALLOGGER
	cd ..
	sed -i 's/ccflags-y += -Wno-implicit-function-declaration -Wno-strict-prototypes -Wno-int-conversion -Wno-gcc-compat/ccflags-y += -Wno-implicit-function-declaration -Wno-strict-prototypes/' KernelSU/kernel/Makefile
	sed -i '/source "drivers\/security\/samsung\/icdrv\/Kconfig"/a source "drivers\/kernelsu\/Kconfig"' drivers/Kconfig
	sed -i 's/# CONFIG_KSU is not set/CONFIG_KSU=y/g' arch/arm64/configs/$DEFCONFIG
else
	echo "KernelSU support is disabled, skipping..."
	rm -rf KernelSU &>> $REALLOGGER
	cd drivers
	rm -rf kernelsu &>> $REALLOGGER
	cd ..
	sed -i '/source "drivers\/kernelsu\/Kconfig"/d' drivers/Kconfig
	sed -i 's/CONFIG_KSU=y/# CONFIG_KSU is not set/g' arch/arm64/configs/$DEFCONFIG
fi

# Cleanup
echo "Cleaning up out directory..."
rm -rf out
mkdir out
rm -rf error.log

# Compile
echo "Compiling the kernel..."
make -j16 O=out clean &>> $REALLOGGER
make -j16 O=out $DEFCONFIG &>> $REALLOGGER
make -j16 ARCH=arm64 O=out SUBARCH=arm64 O=out \
        CC=${REALLOSGCC_DIR}/bin/aarch64-linux-android-gcc \
        LD=${REALLOSGCC_DIR}/bin/aarch64-linux-android-ld.bfd \
        AR=${REALLOSGCC_DIR}/bin/aarch64-linux-android-ar \
        AS=${REALLOSGCC_DIR}/bin/aarch64-linux-android-as \
        NM=${REALLOSGCC_DIR}/bin/aarch64-linux-android-nm \
        OBJCOPY=${REALLOSGCC_DIR}/bin/aarch64-linux-android-objcopy \
        OBJDUMP=${REALLOSGCC_DIR}/bin/aarch64-linux-android-objdump \
        STRIP=${REALLOSGCC_DIR}/bin/aarch64-linux-android-strip \
        CROSS_COMPILE=${REALLOSGCC_DIR}/bin/aarch64-linux-android- &>> $REALLOGGER

# Pack it up
ANYKRANUL=1
DATESTAPLE=`date +%Y%m%d-%H%M`
if [ "$ANYKRANUL" == "1" ]; then
	echo "Packing up with AnyKernel3..."
	rm -rf AnyKernel3
	git clone https://github.com/osm0sis/AnyKernel3 &>> $REALLOGGER
	rm -rf AnyKernel3/modules
	rm -rf AnyKernel3/patch
	rm -rf AnyKernel3/ramdisk
	rm -rf AnyKernel3/LICENSE
	rm -rf AnyKernel3/README.md
	cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3/Image.gz-dtb
	sed -i 's/^kernel.string=.*/kernel.string=/' AnyKernel3/anykernel.sh
	sed -i '/^device.name3=.*/d' AnyKernel3/anykernel.sh
	sed -i '/^device.name4=.*/d' AnyKernel3/anykernel.sh
	sed -i '/^device.name5=.*/d' AnyKernel3/anykernel.sh
	sed -i 's/device.name1=.*/device.name1=a9y18qlte/' AnyKernel3/anykernel.sh
	sed -i 's/device.name2=.*/device.name2=a9y18qltexx/' AnyKernel3/anykernel.sh
	sed -i 's/supported.versions=.*/supported.versions=10/' AnyKernel3/anykernel.sh
	sed -i 's/\/dev\/block\/platform\/omap\/omap_hsmmc.0\/by-name\/boot/\/dev\/block\/platform\/soc\/1da4000.ufshc\/by-name\/boot/' AnyKernel3/anykernel.sh
	sed -i 's/backup_file/\# backup_file/' AnyKernel3/anykernel.sh
	sed -i 's/^replace_string init.rc.*/\# &/' AnyKernel3/anykernel.sh
	sed -i 's/^\(insert_line .*\)$/\# \1/' AnyKernel3/anykernel.sh
	sed -i 's/^\(append_file .*\)$/\# \1/' AnyKernel3/anykernel.sh
	sed -i 's/^patch_fstab.*/\# &/' AnyKernel3/anykernel.sh
	if [ "$KSU" == "1" ]; then
		cd AnyKernel3
		zip -r -9 riaru-ksu-$DATESTAPLE-$DEFCONFIG.zip META-INF tools anykernel.sh Image.gz-dtb &>> $REALLOGGER
		echo "Build is located at: AnyKernel3/riaru-ksu-$DATESTAPLE-$DEFCONFIG.zip"
		cd ..
	else
		cd AnyKernel3
		zip -r -9 riaru-noksu-$DATESTAPLE-$DEFCONFIG.zip META-INF tools anykernel.sh Image.gz-dtb &>> $REALLOGGER
		echo "Build is located at: AnyKernel3/riaru-noksu-$DATESTAPLE-$DEFCONFIG.zip"
		cd ..
	fi
else
	rm -rf AnyKernel3
	echo "Build is located at: out/arch/arm64/boot/Image.gz-dtb"
fi
#!/bin/bash

# Riaru Kernel Simple Build System
# Here is the dependencies to build the kernel
# Debian: apt update && apt upgrade && apt install nano bc bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd sudo make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu python2
# Arch Linux: sudo pacman -S bc bison ca-certificates curl flex glibc openssl openssh wget zip zstd make clang aarch64-linux-gnu-gcc arm-none-eabi-gcc archivetools base-devel python

# Manual clock sync
sudo ln -sf /usr/share/zoneinfo/Asia/Makassar /etc/localtime
sudo hwclock --systohc

# DEFCONFIG
DEFCONFIG=a9y18qlte_defconfig

# LineageOS 19.1 Google GCC 4.9
git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 ../los-gcc
LOSGCC_DIR="../los-gcc"
REALLOSGCC_DIR="$(pwd)"/${LOSGCC_DIR}
sudo chmod 755 -R los-gcc
export PATH="$REALLOSGCC_DIR/bin:$PATH"

# Variables
export KBUILD_BUILD_USER="$USER"
export KBUILD_BUILD_HOST="$HOSTNAME"
export CROSS_COMPILE=aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

# Cleanup
rm -rf out
mkdir out
rm -rf error.log

# Compile
make -j16 O=out clean
make -j16 O=out $DEFCONFIG
make -j16 ARCH=arm64 O=out SUBARCH=arm64 O=out \
        CC=${LOSGCC_DIR}/bin/aarch64-linux-android-gcc \
        LD=${LOSGCC_DIR}/bin/aarch64-linux-android-ld.bfd \
        AR=${LOSGCC_DIR}/bin/aarch64-linux-android-ar \
        AS=${LOSGCC_DIR}/bin/aarch64-linux-android-as \
        NM=${LOSGCC_DIR}/bin/aarch64-linux-android-nm \
        OBJCOPY=${LOSGCC_DIR}/bin/aarch64-linux-android-objcopy \
        OBJDUMP=${LOSGCC_DIR}/bin/aarch64-linux-android-objdump \
        STRIP=${LOSGCC_DIR}/bin/aarch64-linux-android-strip \
        CROSS_COMPILE=${LOSGCC_DIR}/bin/aarch64-linux-android-

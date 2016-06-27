#!/bin/bash

cp -r /opt/kvmfornfv /root/kvmfornfv

# Build qemu debian packages
cd /root/kvmfornfv/qemu
make clean
./configure
make
cd /root/kvmfornfv
mkdir build_qemu_debian
./ci/build_deb/qemu_deb_build.sh build_qemu_debian

# Build kernel debian packages
mkdir build_kernel_debian
./ci/build_deb/kernel_deb_build.sh build_kernel_debian

# Move Kernel and Qemu Debian builds into separate directories
mv /root/debbuild/DEBS/linux-* /opt/kvmfornfv/ci/build_deb/repositories/build_kernel_debian/
mv /root/debbuild/qemu-* /opt/kvmfornfv/ci/build_deb/repositories/build_qemu_debian/

rm -rf build_qemu_debian build_kernel_debian

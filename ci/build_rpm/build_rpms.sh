#!/bin/bash

cp -r /opt/kvmfornfv /root/kvmfornfv

# Build qemu rpm packages
cd /root/kvmfornfv/qemu
make clean
./configure
make
cd /root/kvmfornfv
mkdir build_qemu_rpm
./ci/build_rpm/qemu_rpm_build.sh build_qemu_rpm

# Build kernel rpm packages
mkdir build_kernel_rpm
./ci/build_rpm/kernel_rpm_build.sh build_kernel_rpm

# Move Kernel and Qemu Rpm builds into separate directories
mv /root/rpmbuild/RPMS/x86_64/qemu-* /opt/kvmfornfv/ci/build_rpm/repositories/build_qemu_rpm/
mv /root/kvmfornfv/build_kernel_rpm/kernel-* /opt/kvmfornfv/ci/build_rpm/repositories/build_kernel_rpm/

rm -rf build_qemu_rpm build_kernel_rpm

#!/bin/bash

tmp_rpm_build_dir=/root/kvmfornfv
rpm_build_dir=/opt/kvmfornfv
tmp_rpm_output_dir=$tmp_rpm_build_dir/build_output
rpm_output_dir=$rpm_build_dir/build_output
cp -r $rpm_build_dir $tmp_rpm_build_dir

# Build qemu rpm packages
cd $tmp_rpm_build_dir/qemu
make clean
./configure --target-list=x86_64-softmmu
make -j$(nproc)
cd $tmp_rpm_build_dir
./ci/build_rpm/qemu_rpm_build.sh build_output

# Build kernel rpm packages
./ci/build_rpm/kernel_rpm_build.sh build_output

# Move Kernel and Qemu Rpm builds from tmp_output_dir to output_dir
mv $tmp_rpm_output_dir/qemu-* $rpm_output_dir
mv $tmp_rpm_output_dir/kernel-* $rpm_output_dir

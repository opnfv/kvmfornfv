#!/bin/bash

type=$1

tmp_build_dir=/root/kvmfornfv
build_dir=/opt/kvmfornfv
tmp_output_dir=$tmp_build_dir/build_output
output_dir=$build_dir/build_output
cp -r $build_dir $tmp_build_dir

# Build qemu rpm packages
cd $tmp_build_dir/qemu
make clean
./configure

if [ $type == "centos" ];then
   cd $tmp_build_dir
   ./ci/build_rpm/qemu_rpm_build.sh build_output
   # Build kernel rpm packages
   ./ci/build_rpm/kernel_rpm_build.sh build_output
   # Move Kernel and Qemu Rpm builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/kernel-* $output_dir
elif [ $type == "ubuntu" ];then
   cd $tmp_build_dir
   ./ci/build_deb/qemu_deb_build.sh build_output
   # Build kernel debian packages
   ./ci/build_deb/kernel_deb_build.sh build_output
   # Move Kernel and Qemu Debian builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/linux-* $output_dir
fi

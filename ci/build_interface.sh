#!/bin/bash

type=$1

tmp_build_dir=/root/kvmfornfv
build_dir=/opt/kvmfornfv
tmp_output_dir=$tmp_build_dir/build_output
output_dir=$build_dir/build_output
cp -r $build_dir $tmp_build_dir

# Build qemu rpm packages
cd $tmp_build_dir/qemu
git submodule init
git submodule update --recursive
make clean
./configure

cd $tmp_build_dir
#Build qemu package
./ci/qemu_build.sh build_output $type
# Build kernel packages
./ci/kernel_build.sh build_output $type

if [ $type == "centos" ];then
   # Move Kernel and Qemu Rpm builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/kernel-* $output_dir
elif [ $type == "ubuntu" ];then
   # Move Kernel and Qemu Debian builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/linux-* $output_dir
fi

#!/bin/bash

tmp_deb_build_dir=/root/kvmfornfv
deb_build_dir=/opt/kvmfornfv
tmp_deb_output_dir=$tmp_deb_build_dir/build_output
deb_output_dir=$deb_build_dir/build_output
cp -r $deb_build_dir $tmp_deb_build_dir

# Build qemu debian packages
cd $tmp_deb_build_dir/qemu
make clean
./configure
make
cd $tmp_deb_build_dir
./ci/build_deb/qemu_deb_build.sh build_output

# Build kernel debian packages
./ci/build_deb/kernel_deb_build.sh build_output

# Move Kernel and Qemu Debian builds from tmp_output_dir to output_dir
mv $tmp_deb_output_dir/qemu-* $deb_output_dir
mv $tmp_deb_output_dir/linux-* $deb_output_dir

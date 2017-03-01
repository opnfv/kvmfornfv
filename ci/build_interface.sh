#!/bin/bash

type=$1

tmp_build_dir=/root/kvmfornfv
build_dir=/opt/kvmfornfv
tmp_output_dir=$tmp_build_dir/build_output
output_dir=$build_dir/build_output
cp -r $build_dir $tmp_build_dir

if [ ${apex_build_flag} -eq '0' ];then
   # Build qemu rpm packages
   cd $tmp_build_dir/qemu
   make clean
   ./configure
   cd $tmp_build_dir
   #Build qemu package
   ./ci/qemu_build.sh build_output $type
   # Build kernel packages
   ./ci/kernel_build.sh build_output $type
elif [ ${apex_build_flag} -eq '1' ];then
   cd $tmp_build_dir
   # Building only kernel packages
   echo "Building only kernel rpms" 
   ./ci/kernel_build.sh build_output $type
fi

if [ $type == "centos" ];then
   if [ ${apex_build_flag} -eq '0' ];then
      # Move Kernel and Qemu Rpm builds from tmp_output_dir to output_dir
      mv $tmp_output_dir/qemu-* $output_dir
      mv $tmp_output_dir/kernel-* $output_dir
   elif [ ${apex_build_flag} -eq '1' ];then
      source $WORKSPACE/apex.conf
      # Renaming the rpms in the format kvmfornfv-xxxxxxxx-apex-kernel-4.4.6_rt14.el7.centos.x86_64.rpm
      cd $tmp_output_dir
      short_hash=`git rev-parse --short=8 ${commit_id}`
      rename 's/^/kvmfornfv-'${short_hash}'-apex/' kernel-*
      variable=`ls kvmfornfv-* | awk -F "_" '{print $3}' | awk -F "." '{print $1}'`
      rename "s/${variable}/centos/" kvmfornfv-*
      mv kvmfornfv-* $output_dir
   fi
elif [ $type == "ubuntu" ];then
   # Move Kernel and Qemu Debian builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/linux-* $output_dir
fi

#!/bin/bash

type=$1
flag=$2

tmp_build_dir=/root/kvmfornfv
build_dir=/opt/kvmfornfv
tmp_output_dir=$tmp_build_dir/build_output
output_dir=$build_dir/build_output
cp -r $build_dir $tmp_build_dir

if [ $flag -eq 1 ];then
   echo "Build only kernel rpms"
   cd $tmp_build_dir
   # Build only kernel packages
   ./ci/kernel_build.sh build_output $type $flag
else
   echo "Building both"
   # Build qemu rpm packages
   cd $tmp_build_dir/qemu
   make clean
   ./configure

   cd $tmp_build_dir
   #Build qemu package
   ./ci/qemu_build.sh build_output $type
   # Build kernel packages
   ./ci/kernel_build.sh build_output $type
fi

if [ $type == "centos" ];then
   if [ ${flag} -eq 1 ];then
      source /root/kvmfornfv/apex.conf
      # Renaming the rpms in the format kvmfornfv-xxxxxxxx-apex-kernel-4.4.6_rt14.el7.centos.x86_64.rpm
      echo "${commit_id}"
      short_hash=`git rev-parse --short=8 ${commit_id}`
      echo "$short_hash"
      mv $tmp_output_dir/kernel-* $output_dir
      cd $output_dir
#      ls $output_dir
#      rename 's/^/kvmfornfv-'${short_hash}'-apex-/' kernel-*
#      variable=`ls kvmfornfv-* | grep "devel" | awk -F "_" '{print $3}' | awk -F "." '{print $1}'`
#      rename "s/${variable}/centos/" kvmfornfv-*
   else
      # Move Kernel and Qemu Rpm builds from tmp_output_dir to output_dir
      mv $tmp_output_dir/qemu-* $output_dir
      mv $tmp_output_dir/kernel-* $output_dir
   fi

elif [ $type == "ubuntu" ];then
   # Move Kernel and Qemu Debian builds from tmp_output_dir to output_dir
   mv $tmp_output_dir/qemu-* $output_dir
   mv $tmp_output_dir/linux-* $output_dir
fi

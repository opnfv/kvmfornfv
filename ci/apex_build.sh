#!/bin/bash

function checkout_commit() {
build_dir=/opt/kvmfornfv/
mkdir -p /tmp/kvmfornfv
SRC=/tmp/kvmfornfv
source ${build_dir}/ci/apex.conf
cd $SRC
#Cloning into /tmp/kvmfornfv from local repository
git clone $build_dir $SRC
if [ "$branch" == "master" ] || [ "$branch" == "danube" ];then
   echo "Checking out on $branch branch"
   #git checkout -b $branch
   echo "Commit-id is ${commit_id}"
   git checkout -f ${commit_id}
   if [ $? -ne 0 ];then
      echo "Please check the commit-id provided in apex.conf"
      exit 1
   fi
fi
mkdir ${output_dir}
}

output_dir="$1"
checkout_commit

kernel_src_dir=$SRC/kernel
rpmbuild_dir=$SRC/kvmfornfv_rpmbuild.$$
artifact_dir=${rpmbuild_dir}/RPMS/x86_64
mkdir -p $artifact_dir
config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"

usage () {
    echo "usage: ${0} output_dir"
    exit 1
}


if [[ -z "$@" ]]; then
    usage
fi

if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
    echo "${0}: Output directory '${output_dir}' does not exist or cannot \
          be written"
    exit 1
fi

if [ ! -d ${kernel_src_dir} ] ; then
    echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script \
          from the root of kvmfornfv source tree"
    exit 1
fi

if [ ! -f ${config_file} ] ; then
    echo "${0}: ${config_file} does not exist"
    exit 1
fi

echo
echo "Build"
echo

cp -f ${config_file} "${kernel_src_dir}/.config"

# Make timestamp part of version string for automated kernel boot verification
date "+-%y%m%d%H%M" > "${kernel_src_dir}/localversion-zzz"

(cd ${kernel_src_dir}; make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg)
if [ ${?} -ne 0 ] ; then
    echo "${0}: Kernel build failed"
    rm -rf ${rpmbuild_dir}
    exit 1
fi

cp -f ${artifact_dir}/* ${output_dir}
mv ${output_dir}/* ${build_dir}/build_output/

rm -rf ${rpmbuild_dir}
#cleaning the /tmp
rm -rf ${SRC}

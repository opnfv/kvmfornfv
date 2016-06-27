#!/bin/bash
kernel_src_dir=kernel
rpmbuild_tmp='/tmp'
rpmbuild_dir=$rpmbuild_tmp/kvmfornfv_rpmbuild.$$
echo $rpmbuild_dir
mkdir -p $rpmbuild_dir
artifact_rpms=$rpmbuild_dir/RPMS
mkdir -p $artifact_rpms
artifact_dir=$artifact_rpms/x86_64
mkdir -p $artifact_dir

config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"
output_dir="$1"

usage () {
    echo "usage: ${0} output_dir"
    exit 1
}

if [[ -z "$@" ]]; then
    usage
fi

if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
    echo "${0}: Output directory '${output_dir}' does not exist or cannot be written"
    exit 1
fi

if [ ! -d ${kernel_src_dir} ] ; then
    echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
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

( cd ${kernel_src_dir}; make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg )
if [ ${?} -ne 0 ] ; then
    echo "${0}: Kernel build failed"
    rm -rf ${rpmbuild_dir}
    exit 1
fi

rm -rf ${rpmbuild_dir}

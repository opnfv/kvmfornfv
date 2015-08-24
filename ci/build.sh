#!/bin/bash

if [ ${#} -ne 1 ] ; then
    echo "usage: ${0} output_dir"
    exit -1
fi

if [ ! -d ${1} ] ; then
    echo ${0}: Output directory \'${1}\' does not exist
    exit -1
fi
output_dir=${1}

kernel_src_dir=kernel
if [ ! -d ${kernel_src_dir} ] ; then
    echo ${0}: Directory \'${kernel_src_dir}\' does not exist, run this script from the root of kvmfornfv source tree
    exit -1
fi

cd ${kernel_src_dir}

echo
echo "Build"
echo "-----"
echo

config_file=arch/x86/configs/opnfv.config
if [ ! -f ${config_file} ] ; then
    echo ${0}: ${config_file} does not exist
    exit -1
fi
cp -f ${config_file} .config

rpmbuild_dir=/tmp/kvmfornfv_rpmbuild
artifact_dir=${rpmbuild_dir}/RPMS/x86_64

rm -rf ${rpmbuild_dir}

make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg
if [ ${?} -ne 0 ] ; then
    echo ${0}: Kernel build failed
    exit -1
fi

# Make sure the build was successful
if [ ! -d ${artifact_dir} ] ; then
    echo ${0}: Kernel RPM packages build failed
    exit -1
fi

RPMs=`ls -1 ${artifact_dir} | wc -w`
if [ ${RPMs} -ne 3 ] ; then
    echo ${0}: Only ${RPMs} RPM packages were built
    exit -1
fi

cp -f ${artifact_dir}/* ${output_dir}

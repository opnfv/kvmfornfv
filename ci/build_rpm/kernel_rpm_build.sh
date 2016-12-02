#!/bin/bash
rpmbuild_dir=/tmp/kvmfornfv_rpmbuild.$$
artifact_dir=${rpmbuild_dir}/RPMS/x86_64
mkdir -p $artifact_dir

source ./functions

kernel_build_validate $@

kernel_build_prep

# Make timestamp part of version string for automated kernel boot verification
date "+-%y%m%d%H%M" > "${kernel_src_dir}/localversion-zzz"

(cd ${kernel_src_dir}; make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg)
if [ ${?} -ne 0 ] ; then
    echo "${0}: Kernel build failed"
    rm -rf ${rpmbuild_dir}
    exit 1
fi

cp -f ${artifact_dir}/* ${output_dir}

rm -rf ${rpmbuild_dir}

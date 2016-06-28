#!/bin/bash
qemu_src_dir=qemu
workspace=/root
debbuild_dir=$workspace/debbuild
rpmbuild_dir=$workspace/rpmbuild
artifact_rpms=$rpmbuild_dir/RPMS
artifact_dir=$artifact_rpms/x86_64
scripts_dir=ci/build_qemu_rpm_deb
output_dir="$1"
VERSION=`grep -m 1 "VERSION" scripts/config-host.mak | cut -d= -f2-`

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

if [ ! -d ${qemu_src_dir} ] ; then
    echo "${0}: Directory '${qemu_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
    exit 1
fi

echo
echo "Build"
echo

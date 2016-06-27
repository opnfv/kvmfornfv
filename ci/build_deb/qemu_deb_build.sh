#!/bin/bash

qemu_src_dir=qemu
workspace=/root
debbuild_dir=$workspace/debbuild
scripts_dir=ci/build_deb
output_dir="$1"
VERSION=`grep -m 1 "VERSION"  ${qemu_src_dir}/config-host.mak | cut -d= -f2-`

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

qemu_deb_build() {
    mkdir -p $debbuild_dir/qemu-$VERSION
    cp -r $qemu_src_dir $debbuild_dir/qemu-$VERSION
    mkdir -p $debbuild_dir/qemu-$VERSION/DEBIAN
    touch control

#creating control file for debian build.
    (cd ${scripts_dir}; ./mkcontrol.sh $VERSION > control)
    mv $scripts_dir/control $debbuild_dir/qemu-$VERSION/DEBIAN/control

#building the qemu debian with control file developed.
    dpkg-deb --build $debbuild_dir/qemu-$VERSION
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi
}

if [ ! -d ${debbuild_dir} ] ; then
    echo "creating debbuild directory"
    mkdir -p $debbuild_dir
fi

qemu_deb_build
latest_qemu_build=`ls -rt $debbuild_dir | tail -1`
cp $debbuild_dir/$latest_qemu_build build_output

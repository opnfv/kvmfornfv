#!/bin/bash

debbuild_dir=$workspace/debbuild
source ./ci/qemuConfigValidate.sh

qemu_build_validate $@

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

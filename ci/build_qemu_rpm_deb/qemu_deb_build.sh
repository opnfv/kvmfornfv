#!/bin/bash
#Build process for generating qemu debain file.

source ci/build_qemu_rpm_deb/qemu_build.sh
qemu_deb_build() {
    sudo mkdir -p $debbuild_dir/qemu-$VERSION
    sudo cp -r $qemu_src_dir $debbuild_dir/qemu-$VERSION
    sudo mkdir -p $debbuild_dir/qemu-$VERSION/DEBIAN
    sudo touch control

#creating control file for debian build.
    (cd ${scripts_dir}; sudo ./mkcontrol.sh $VERSION > control)
    sudo mv $scripts_dir/control $debbuild_dir/qemu-$VERSION/DEBIAN/control

#building the qemu debian with control file developed.
    sudo dpkg-deb --build $debbuild_dir/qemu-$VERSION
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi
}

if [ ! -d ${debbuild_dir} ] ; then
    echo "creating debbuild directory"
    sudo mkdir -p $debbuild_dir
fi

qemu_deb_build
latest_qemu_build=`sudo ls -rt $debbuild_dir | tail -1`
sudo cp $debbuild_dir/$latest_qemu_build build_output

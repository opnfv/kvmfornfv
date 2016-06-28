#!/bin/bash
qemu_src_dir=qemu
workspace=/root
debbuild_dir=$workspace/debbuild
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

if [ ! -d ${qemu_src_dir} ] ; then
    echo "${0}: Directory '${qemu_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
    exit 1
fi


echo
echo "Build"
echo


debianbuild() {
    sh ${qemu_src_dir}/qemu_build.sh ${qemu_src_dir} ${debbuild_dir} debian_build
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi

}
if [ ! -d ${debbuild_dir} ] ; then
    echo "creating debbuild directory"
    sudo mkdir -p $debbuild_dir
    debianbuild
fi
debianbuild
latest_qemu_build=`sudo ls -rt $debbuild_dir | tail -1`
sudo cp $debbuild_dir/$latest_qemu_build build_output

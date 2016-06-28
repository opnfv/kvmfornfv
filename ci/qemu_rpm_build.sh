#!/bin/bash
qemu_src_dir=qemu
workspace=/root
rpmbuild_dir=$workspace/rpmbuild
artifact_rpms=$rpmbuild_dir/RPMS
artifact_dir=$artifact_rpms/x86_64

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
echo "build"
echo


rpmbuild() {
    sh ${qemu_src_dir}/qemu_build.sh ${qemu_src_dir} ${rpmbuild_dir} rpm_build

    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        rm -rf ${rpmbuild_dir}
        exit 1
    fi
}

if [ ! -d ${rpmbuild_dir} ] ; then
    sudo yum install rpm-build -y
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    sudo mv rpmbuild $workspace
    rpmbuild
fi

rpmbuild
latest_qemu_build=`ls -rt $artifact_dir | grep qemu-2.6* | tail -1`
sudo cp $artifact_dir/$latest_qemu_build build_output

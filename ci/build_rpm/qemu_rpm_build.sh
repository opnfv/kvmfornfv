#!/bin/bash

qemu_src_dir=qemu
workspace=/root
rpmbuild_dir=$workspace/rpmbuild
artifact_rpms=$rpmbuild_dir/RPMS
artifact_dir=$artifact_rpms/x86_64
scripts_dir=ci/build_rpm
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

qemu_rpm_build() {
    cp  -r ${qemu_src_dir}  ${qemu_src_dir}-$VERSION
    tar -zcvf ${qemu_src_dir}-$VERSION.tar.gz ${qemu_src_dir}-$VERSION
    mv ${qemu_src_dir}-$VERSION.tar.gz ${rpmbuild_dir}/SOURCES/

    #create a spec file for rpm creation.
    (cd ${scripts_dir}; ./mkspec $VERSION > qemu.spec)
    cp ${scripts_dir}/qemu.spec ${rpmbuild_dir}/SPECS/

    #build the qemu rpm with spec file developed
    rpmbuild -ba ${rpmbuild_dir}/SPECS/qemu.spec
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi
    rm -rf ${qemu_src_dir}-$VERSION
    rm -rf ${rpmbuild_dir}/SOURCES/${qemu_src_dir}-$VERSION.tar.gz
}

if [ ! -d ${rpmbuild_dir} ] ; then
    yum install rpm-build -y
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    mv rpmbuild $workspace
fi

qemu_rpm_build
latest_qemu_build=`ls -rt $artifact_dir | grep qemu-2.6* | tail -1`
cp $artifact_dir/$latest_qemu_build build_output

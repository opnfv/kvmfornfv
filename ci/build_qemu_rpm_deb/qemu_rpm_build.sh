#!/bin/bash
#Build process for Generating qemu rpm.

source ci/build_qemu_rpm_deb/qemu_build.sh
qemu_rpm_build() {
    sudo cp  -r ${qemu_src_dir}  ${qemu_src_dir}-$VERSION
    sudo tar -zcvf ${qemu_src_dir}-$VERSION.tar.gz ${qemu_src_dir}-$VERSION
    sudo mv ${qemu_src_dir}-$VERSION.tar.gz ${rpmbuild_dir}/SOURCES/

#create a spec file for rpm creation.
    (cd ${scripts_dir}; ./mkspec $VERSION > qemu.spec)
    sudo cp ${scripts_dir}/qemu.spec ${rpmbuild_dir}/SPECS/

#build the qemu rpm with spec file developed
    sudo rpmbuild -ba ${rpmbuild_dir}/SPECS/qemu.spec
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi
    sudo rm -rf ${qemu_src_dir}-$VERSION
    sudo rm -rf ${rpmbuild_dir}/SOURCES/${qemu_src_dir}-$VERSION.tar.gz
}

if [ ! -d ${rpmbuild_dir} ] ; then
    sudo yum install rpm-build -y
    mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    sudo mv rpmbuild $workspace
fi

qemu_rpm_build
latest_qemu_build=`ls -rt $artifact_dir | grep qemu-2.6* | tail -1`
sudo cp $artifact_dir/$latest_qemu_build build_output

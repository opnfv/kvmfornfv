#!/bin/bash

rpmbuild_dir=$workspace/rpmbuild
artifact_rpms=$rpmbuild_dir/RPMS
artifact_dir=$artifact_rpms/x86_64
source ./ci/qemuConfigValidate.sh

qemu_build_validate $@

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
    mkdir -p ${rpmbuild_dir}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
fi

qemu_rpm_build
latest_qemu_build=`ls -rt $artifact_dir | grep qemu-2.6* | tail -1`
cp $artifact_dir/$latest_qemu_build ${output_dir}

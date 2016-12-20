#!/bin/bash

source ./ci/qemuConfigValidate.sh
rpmbuild_dir=$workspace/rpmbuild
artifact_rpms=$rpmbuild_dir/RPMS
artifact_dir=$artifact_rpms/x86_64
debbuild_dir=$workspace/debbuild

qemu_build_validate $@

qemu_rpm_build() {
    scripts_dir=ci/build_rpm
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

qemu_deb_build() {
    scripts_dir=ci/build_deb
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

if [ $pkgtype == "centos" ];then
   if [ ! -d ${rpmbuild_dir} ] ; then
      mkdir -p ${rpmbuild_dir}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
   fi
   qemu_rpm_build
   latest_qemu_build=`ls -rt $artifact_dir | grep qemu-2.6* | tail -1`
   cp $artifact_dir/$latest_qemu_build ${output_dir}
elif [ $pkgtype == "ubuntu" ];then
   if [ ! -d ${debbuild_dir} ] ; then
      echo "creating debbuild directory"
      mkdir -p $debbuild_dir
   fi
   qemu_deb_build
   latest_qemu_build=`ls -rt $debbuild_dir | tail -1`
   cp $debbuild_dir/$latest_qemu_build build_output
fi

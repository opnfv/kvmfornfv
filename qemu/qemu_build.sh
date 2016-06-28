#!/bin/bash
VERSION=`grep -m 1 "VERSION" qemu/config-host.mak | cut -d= -f2-`
echo $VERSION
qemu_src_dir=$1
qemu_des_dir=$2


qemu_rpm_build() {

    sudo cp  -r ${qemu_src_dir}  ${qemu_src_dir}-$VERSION
    sudo tar -zcvf ${qemu_src_dir}-$VERSION.tar.gz ${qemu_src_dir}-$VERSION
    sudo cp -r ${qemu_src_dir}-$VERSION.tar.gz ${qemu_des_dir}/SOURCES/

#create a spec file for rpm creation.
    (cd ${qemu_src_dir}; ./mkspec $VERSION > qemu.spec)
    sudo cp ${qemu_src_dir}/qemu.spec ${qemu_des_dir}/SPECS/

#build the qemu rpm with spec file developed
    sudo rpmbuild -ba ${qemu_des_dir}/SPECS/qemu.spec
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi 
    sudo rm -rf ${qemu_src_dir}-$VERSION*
    sudo rm -rf ${qemu_des_dir}/SOURCES/${qemu_src_dir}-$VERSION.tar.gz

}

qemu_deb_build() {
    sudo mkdir -p $qemu_des_dir/qemu-$VERSION
    sudo cp -r $qemu_src_dir $qemu_des_dir/qemu-$VERSION
    sudo mkdir -p $qemu_des_dir/qemu-$VERSION/DEBIAN
    sudo touch control

#creating control file for debian build.
    (cd ${qemu_src_dir}; sudo ./mkcontrol.sh $VERSION > control)
    echo $qemu_des_dir
    sudo mv $qemu_src_dir/control $qemu_des_dir/qemu-$VERSION/DEBIAN/control

#building the qemu debian with control file developed.
    sudo dpkg-deb --build $qemu_des_dir/qemu-$VERSION
    if [ ${?} -ne 0 ] ; then
        echo "${0}: qemu build failed"
        exit 1
    fi

}

if [ "$2" = "/root/rpmbuild" ]; then
    echo "starting qemu rpm build"
    qemu_rpm_build

elif [ "$2" = "/root/debbuild" ]; then
    echo "starting qemu debian build"
    qemu_deb_build

else
    echo "Destination for qemu build is not correct"

fi









#!/bin/bash

set -eux
cp -r ../kvmfornfv .
BUILD_FOR=${BUILD_FOR:-ubuntu}
DIR="$(dirname `readlink -f $0`)"

function build_deb_pkg {
    case $1 in
        ubuntu)
            sudo docker build -t kvm_deb .
            container_id=`sudo docker run -d kvm_deb`
            sudo docker cp $container_id:/root/kvmfornfv/build_kernel_debian/. ${DIR}/repositories
            sudo docker cp $container_id:/root/kvmfornfv/build_qemu_debian/. ${DIR}/repositories
            sudo rm -rf kvmfornfv
        ;;
        *) echo "Not supported system"; exit 1;;
    esac
}

for system in $BUILD_FOR
do
    build_deb_pkg $system
done


#!/bin/bash

set -eux
sudo cp -r ../kvmfornfv .
BUILD_FOR=${BUILD_FOR:-centos}
DIR="$(dirname `readlink -f $0`)"

function build_rpm_pkg {
    case $1 in
        centos)
            sudo docker build -t kvm_rpm .
            container_id=`sudo docker run -d kvm_rpm`
            sudo docker cp $container_id:/root/kvmfornfv/build_kernel_rpm/. ${DIR}/repositories
            sudo docker cp $container_id:/root/kvmfornfv/build_qemu_rpm/. ${DIR}/repositories
            sudo rm -rf kvmfornfv
        ;;
        *) echo "Not supported system"; exit 1;;
    esac
}

for system in $BUILD_FOR
do
    build_rpm_pkg $system
done


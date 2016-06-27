#!/bin/bash

set -eux
BUILD_FOR=${BUILD_FOR:-centos}
DIR="$(dirname `readlink -f $0`)"

function build_rpm_pkg {
  case $1 in
    centos)
      rm -rf repositories/build_kernel_rpm repositories/build_qemu_rpm
      mkdir -p repositories/build_kernel_rpm repositories/build_qemu_rpm
      sudo docker build -t kvm_rpm .
      sudo docker run -v ${DIR}/../..:/opt/kvmfornfv -t  kvm_rpm /opt/kvmfornfv/ci/build_rpm/build_rpms.sh
    ;;
    *) echo "Not supported system"; exit 1;;
  esac
}

for system in $BUILD_FOR
do
  build_rpm_pkg $system
done

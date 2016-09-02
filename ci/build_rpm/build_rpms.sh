#!/bin/bash

set -eux
BUILD_FOR=${BUILD_FOR:-centos}

function build_rpm_pkg {
  case $1 in
    centos)
      sudo docker build -t kvm_rpm .
      sudo docker run --cpu-shares=0 -v $WORKSPACE:/opt/kvmfornfv -t  kvm_rpm \
                      /opt/kvmfornfv/ci/build_rpm/build_rpms_docker.sh
    ;;
    *) echo "Not supported system"; exit 1;;
  esac
}

for system in $BUILD_FOR
do
  build_rpm_pkg $system
done

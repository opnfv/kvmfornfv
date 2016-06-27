#!/bin/bash

cd /root/kvmfornfv
cp build_rpm_kvm.sh ci/build.sh
mkdir build_output
chmod 755 ci/build.sh
./ci/build.sh build_output

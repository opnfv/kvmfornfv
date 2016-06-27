#!/bin/bash
export http_proxy=http://10.138.77.10:3128
export https_proxy=https://10.138.77.10:3128
cd /root
#git clone https://gerrit.opnfv.org/gerrit/kvmfornfv
cp build.sh kvmfornfv/ci/build.sh
cd kvmfornfv
mkdir build_output
chmod 755 ci/build.sh
./ci/build.sh build_output

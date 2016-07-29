#!/bin/bash

MYDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $MYDIR/../host-config

DPDK_ROOT=${DPDK_ROOT:-/home/nfv/dpdk/}
OVS_DIR=${OVS_DIR:-/home/nfv/ovs/}

if [ ! -d $DPDK_ROOT ] || [ ! -d $OVS_DIR ]
then
	echo "DPDK or OVS directory wrong."
	echo "DPDK is set as $DPDK_ROOT"
	echo "OVS is set as $OVS_DIR"
	exit 1
fi

export DPDK_ROOT=$DPDK_ROOT

cd $DPDK_ROOT
make -j32 install T=x86_64-native-linuxapp-gcc
cd -

export DPDK_BUILD=$DPDK_ROOT/x86_64-native-linuxapp-gcc/
#sudo yum install -y python-six

cd $OVS_DIR
./boot.sh
./configure --with-dpdk=$DPDK_BUILD CFLAGS="-O3 -march=native -Wno-cast-align"
sudo make -j32 install
cd -

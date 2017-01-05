#!/bin/bash

###############################################################################
Copyright (c) 2016 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

source utils.sh
source host-config

QEMU_VERSION=$( getQemuVersion )

if [ -z $QEMU_VERSION ];then
   echo "qemu RPM not found"
   exit 1
fi
rpmdir=${1:-"/root/workspace/rpm/"}
rpmpat="qemu-${QEMU_VERSION}*.rpm"

install_qemu () {
    # Install the qemu rpm
    filenum=`ls -l ${rpmdir}/${rpmpat} |wc -l`
    if [ $filenum -eq 0 ]
    then
        echo "No qemu rpm found in workspace/rpm"
        exit 1
    elif [ $filenum -gt 1 ]
    then
        echo "Multiple qemu rpm found in workspace/rpm"
        exit 1
    else
       qrpm=`find "${rpmdir}" -name "${rpmpat}"`
        rpm -ihv $qrpm
    fi
}
install_qemu

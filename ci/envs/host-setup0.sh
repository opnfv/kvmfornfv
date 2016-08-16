#!/bin/bash

##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################
set -x

source host-config

rpmdir=${1:-"/root/workspace/rpm/"}
rpmpat="kernel-[0-9].*.rpm"

config_grub () {
    key=$1
    val=$2

    if  grep '[" ]'${key} /etc/default/grub > /dev/null ; then
        sed -i  's/\([" ]\)'${key}'=[^ "]*/\1'${key}'='${val}'/' /etc/default/grub
    else
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 '${key}'='${val}'"/' /etc/default/grub
    fi
}

# The script's caller should passing the rpm directory that is built out from 
# build.sh. The default rpmdir is the one used by yardstick scripts.
install_kernel () {
    # Install the kernel rpm
    filenum=`ls -l ${rpmdir}/${rpmpat} |wc -l`
    if [ $filenum -eq 0 ]
    then
    	echo "No kernel rpm found in workspace/rpm"
    	exit 1
    elif [ $filenum -gt 1 ]
    then
    	echo "Multiple kernel rpm found in workspace/rpm"
    	rm -f ${rpmdir}/*
    	exit 1
    else
    	krpm=`find "${rpmdir}" -name "${rpmpat}"`
    	rpm -ihv $krpm
    fi
}

# Isolate CPUs from the general scheduler
config_grub 'isolcpus' ${host_isolcpus}

# Stop timer ticks on isolated CPUs whenever possible
config_grub 'nohz_full' ${host_isolcpus}

# Do not call RCU callbacks on isolated CPUs
config_grub 'rcu_nocbs' ${host_isolcpus}

# Enable intel iommu driver and disable DMA translation for devices
config_grub 'iommu' 'pt'
config_grub 'intel_iommu' 'on'

# Set HugeTLB pages to 1GB
config_grub 'default_hugepagesz' '1G'
config_grub 'hugepagesz' '1G'

# Disable machine check
config_grub 'mce' 'off'

## Use polling idle loop to improve performance
config_grub 'idle' 'poll'

## Disable clocksource verification at runtime
config_grub 'tsc' 'reliable'

grub2-mkconfig -o /boot/grub2/grub.cfg

install_kernel

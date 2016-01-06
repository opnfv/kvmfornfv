#!/bin/bash

##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

source host-config


##############################
# Create 1GB pages for guest #
##############################

hugepage_size=`cat /proc/meminfo  |grep Hugepagesize |tr -s " "| cut -f 2 -d " "`
if [[ $hugepage_size -ne 1048576 ]]
then
    echo "Need 1G huge page support for performance benefit"
    exit 1
fi

mkdir -p /mnt/hugetlbfs-1g
mount -t hugetlbfs hugetlbfs /mnt/hugetlbfs-1g -osize=1G

hugepage_dir="/sys/devices/system/node/node${numa_node}/hugepages/hugepages-1048576kB/nr_hugepages"

huge_pages+=`cat $hugepage_dir`
echo ${huge_pages} > ${hugepage_dir}

############################
# RT optimization	   #
############################
# Disable watchdogs to reduce overhead
echo 0 > /proc/sys/kernel/watchdog
echo 0 > /proc/sys/kernel/nmi_watchdog

# Change RT priority of ksoftirqd and rcuc kernel threads on isolated CPUs
i=0
for c in `echo $host_isolcpus | sed 's/,/ /g'` ; do
    tid=`pgrep -a ksoftirq | grep "ksoftirqd/${c}$" | cut -d ' ' -f 1`
    chrt -fp 2 ${tid}

    tid=`pgrep -a rcuc | grep "rcuc/${c}$" | cut -d ' ' -f 1`
    chrt -fp 3 ${tid}

    cpu[$i]=${c}
    i=`expr $i + 1`
done

# Change RT priority of rcub kernel threads
for tid in `pgrep -a rcub | cut -d ' ' -f 1` ; do
    chrt -fp 3 ${tid}
done

# Disable RT throttling
echo -1 > /proc/sys/kernel/sched_rt_period_us
echo -1 > /proc/sys/kernel/sched_rt_runtime_us

# Reroute interrupts bound to isolated CPUs to CPU 0
for irq in /proc/irq/* ; do
    if [ -d ${irq} ] && ! grep - ${irq}/smp_affinity_list > /dev/null ; then
        al=`cat ${irq}/smp_affinity_list`
        if [[ ${cpu[*]} =~ ${al} ]] ; then
            echo 0 > ${irq}/smp_affinity_list
        fi
    fi
done

# Change the iptable so that we can ssh to the guest remotely
iptables -I INPUT -p tcp --dport 5555 -j ACCEPT
# TODO: download guest disk image from artifactory


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

cpumask () {
    m=$((1<<${1}))
    printf 0x%x ${m}
}

qmp_sock="/tmp/qmp-sock-$$"

#${qemu} -smp ${guest_cpus} -monitor unix:${qmp_sock},server,nowait -daemonize \
#    -cpu host,migratable=off,+invtsc,+tsc-deadline,pmu=off \
#    -realtime mlock=on -mem-prealloc -enable-kvm -m 1G \
#    -mem-path /mnt/hugetlbfs-1g \
#    -drive file=/root/minimal-centos1.qcow2,cache=none,aio=threads \
#    -netdev user,id=guest0,hostfwd=tcp:10.2.117.23:5555-:22 \
#    -device virtio-net-pci,netdev=guest0 \
#    -nographic -serial /dev/null -parallel /dev/null

#/usr/libexec/qemu-kvm -drive file=/root/guest.qcow2 -daemonize -netdev  user,id=net0,hostfwd=tcp:10.2.117.23:5555-:22 -device virtio-net-pci,netdev=net0 &
/usr/libexec/qemu-kvm -drive file=/root/guest1.qcow2 -daemonize -netdev user,id=net0,hostfwd=tcp:10.2.117.23:5555-:22 -device e1000,netdev=net0 -realtime mlock=on -mem-prealloc -enable-kvm -m 1G -mem-path /mnt/hugetlbfs-1g

i=0
for c in `echo ${host_isolcpus} | sed 's/,/ /g'` ; do
    cpu[$i]=${c}
    i=`expr $i + 1`
done

threads=`echo "info cpus" | nc -U ${qmp_sock} | grep thread_id | cut -d= -f3`

# Bind QEMU processor threads to RT CPUs
i=0
for tid in ${threads} ; do
    tid=`printf %d ${tid}`  # this is required to get rid of cr at end
    mask=`cpumask ${cpu[$i]}`
    taskset -p ${mask} ${tid}
    i=`expr $i + 1`
done

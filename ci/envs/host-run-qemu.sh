#!/bin/bash

##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

source utils.sh
source host-config

HOST_IP=$( getHostIP )

cpumask () {
    m=$((1<<${1}))
    printf 0x%x ${m}
}

qmp_sock="/tmp/qmp-sock"

#${qemu} -smp ${guest_cpus} -monitor unix:${qmp_sock},server,nowait -daemonize \
#    -cpu host,migratable=off,+invtsc,+tsc-deadline,pmu=off \
#    -realtime mlock=on -mem-prealloc -enable-kvm -m 1G \
#    -mem-path /mnt/hugetlbfs-1g \
#    -drive file=/root/minimal-centos1.qcow2,cache=none,aio=threads \
#    -netdev user,id=guest0,hostfwd=tcp:10.2.117.23:5555-:22 \
#    -device virtio-net-pci,netdev=guest0 \
#    -nographic -serial /dev/null -parallel /dev/null

${qemu} -smp ${guest_cpus} -monitor unix:${qmp_sock},server,nowait \
     -cpu host,migratable=off,+invtsc,+tsc-deadline,pmu=off
     -drive file=/root/guest1.qcow2 -daemonize \
     -netdev user,id=net0,hostfwd=tcp:$HOST_IP:5555-:22 \
     -realtime mlock=on -mem-prealloc -enable-kvm -m 1G \
     -mem-path /mnt/hugetlbfs-1g \
     -device virtio-net-pci,netdev=net0 \
     -vnc :1

threads=`echo "info cpus" | nc -U ${qmp_sock} | grep thread_id | cut -d= -f3`

# Bind QEMU processor threads to RT CPUs
i=0
for tid in ${threads} ; do
    new_tid=`echo $tid | sed -e 's/[\r\n]//g'` # this is required to get rid of cr at end
    mask=`cpumask ${qemu_cpu[$i]}`
    taskset -p ${mask} ${new_tid}
    i=`expr $i + 1`
done

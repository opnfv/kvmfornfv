#!/bin/bash

source host-config

cpumask () {
    m=$((1<<${1}))
    printf 0x%x ${m}
}

qmp_sock="/tmp/qmp-sock"

${qemu} -smp ${guest_cpus} -monitor unix:${qmp_sock},server,nowait -daemonize \
    -cpu host,migratable=off,+invtsc,+tsc-deadline,pmu=off \
    -realtime mlock=on -mem-prealloc -enable-kvm -m 1G \
    -drive file=guest.img,cache=none,aio=threads \
    -netdev user,id=guest0,hostfwd=tcp::5555-:22 \
    -device virtio-net-pci,netdev=guest0 \
    -nographic -serial /dev/null -parallel /dev/null

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

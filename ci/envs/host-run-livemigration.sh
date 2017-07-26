#!/bin/bash

##############################################################################
##Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

source utils.sh
source host-config

HOST_IP=$( getHostIP )
#source qmp-sock for conmunication with qemu
qmp_sock_src="/tmp/qmp-sock-src"
#destination qmp-sock for conmunication with qemu, only for local live migration
qmp_sock_dst="/tmp/qmp-sock-dst"

VHOSTPATH1='/usr/local/var/run/openvswitch/vhost-user1'
VHOSTPATH2='/usr/local/var/run/openvswitch/vhost-user2'

VHOSTPATH3='/usr/local/var/run/openvswitch/vhost-user3'
VHOSTPATH4='/usr/local/var/run/openvswitch/vhost-user4'

MACADDRESS1='52:54:00:12:34:56'
MACADDRESS2='54:54:00:12:34:56'

#destination host ip address
incoming_ip=0
migrate_port=4444
max_down_time=10


OVSLOGFILE='/var/log/openvswitch/ovs-vswitchd.log'

function run_qemusrc() {
  $qemu -enable-kvm -cpu host -smp ${guest_cpus} -chardev socket,id=char1,path=$VHOSTPATH1 \
        -netdev type=vhost-user,id=net1,chardev=char1,vhostforce \
        -device virtio-net-pci,netdev=net1,mac=$MACADDRESS1 \
        -chardev socket,id=char2,path=$VHOSTPATH2 \
        -netdev type=vhost-user,id=net2,chardev=char2,vhostforce \
        -device virtio-net-pci,netdev=net2,mac=$MACADDRESS2 -m 1024 -mem-path /dev/hugepages \
        -mem-prealloc -realtime mlock=on -monitor unix:${qmp_sock_src},server,nowait \
        -balloon virtio -drive file=/root/guest1.qcow2 -vnc :1 &
  if [ ${?} -ne 0 ] ; then
    echo "Qemu Source not started"
    exit 1
  fi
}

function run_qemulisten() {
  $qemu -enable-kvm -cpu host -smp ${guest_cpus} -chardev socket,id=char1,path=$VHOSTPATH3 \
  -netdev type=vhost-user,id=net1,chardev=char1,vhostforce \
  -device virtio-net-pci,netdev=net1,mac=$MACADDRESS1 \
  -chardev socket,id=char2,path=$VHOSTPATH4 \
  -netdev type=vhost-user,id=net2,chardev=char2,vhostforce \
  -device virtio-net-pci,netdev=net2,mac=$MACADDRESS2 -m 1024 -mem-path /dev/hugepages \
  -mem-prealloc -realtime mlock=on -monitor unix:${qmp_sock_dst},server,nowait \
  -balloon virtio -drive file=/root/guest1.qcow2 -incoming tcp:${incoming_ip}:${migrate_port} -vnc :3 &
  if [ ${?} -ne 0 ] ; then
    echo "Qemu Standby not started"
    exit 1
  fi
}

function do_migration() {

  local src=$1
  local dst=$2
#with no speed limit
  echo "migrate_set_speed 0" |nc -U $src
#set the expected max downtime
  echo "migrate_set_downtime ${max_down_time}" |nc -U $src
#start live migration
  echo "migrate -d tcp:${incoming_ip}:${migrate_port}" |nc -U $src
#wait until live migration completed
  status=""
  while [  "${status}" == ""  ]
  do
     status=`echo "info migrate" | nc -U $src |grep completed | cut -d: -f2`
     echo ${status}
     sleep 1;
  done
#get the related data
 status=`echo "info migrate" | nc -U $src |grep completed | cut -d: -f2`
 total_time=`echo "info migrate" | nc -U $src |grep "total time" | cut -d: -f2`
 down_time=`echo "info migrate" | nc -U $src |grep "downtime" | cut -d: -f2`

#print detail information
 echo "info migrate" | nc -U $src
 echo "quit" | nc -U $src
 sleep 5
 exit 0
 echo "Migration executed successfully"
}
echo "Running Qemu Source"
run_qemusrc
sleep 60
echo "Running Qemu listen"
run_qemulisten
sleep 60
do_migration $qmp_sock_src $qmp_sock_dst
if [ ${?} -ne 0 ] ; then
   echo "Migration Failed"
   exit 1
fi

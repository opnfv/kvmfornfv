#!/bin/bash

###########################################################
## Invoking this script from ubuntu docker container runs
## cyclictest through yardstick
###########################################################
source utils.sh

HOST_IP=$( getHostIP )
pod_config='/opt/pod.yaml'
cyclictest_context_file='/opt/cyclictest-node-context.yaml'

if [ ! -f ${pod_config} ] ; then
    echo "file ${pod_config} not found"
    exit 1
fi

if [ ! -f ${cyclictest_context_file} ] ; then
    echo "file ${cyclictest_context_file} not found"
    exit 1
fi

#setting up of image for launching guest vm.
sudo ssh root@$HOST_IP "cp /root/images/guest1.qcow2 /root/"

#Running cyclictest through yardstick
yardstick -d task start ${cyclictest_context_file}
if [ $? == 1 ];then
   exit 1
fi
chmod 777 /tmp/yardstick.out
cat /tmp/yardstick.out  > /opt/yardstick.out

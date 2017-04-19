#!/bin/bash

###########################################################
## Invoking this script from ubuntu docker container runs
## cyclictest through yardstick
###########################################################
source utils.sh

testType=$1 #daily/verify/merge
testName=$2 #idle_idle/stress_idle
HOST_IP=$( getHostIP )
pod_config='/opt/scripts/pod.yaml'
cyclictest_context_file='/opt/kvmfornfv_cyclictest_'${testName}'.yaml'
yardstick_prefix='/root/yardstick/yardstick/benchmark/scenarios/compute'

if [ ! -f ${pod_config} ] ; then
    echo "file ${pod_config} not found"
    exit 1
fi

if [ ! -f ${cyclictest_context_file} ] ; then
    echo "file ${cyclictest_context_file} not found"
    exit 1
fi

#copy the post-execute scripts to the path/prefix used by yardstick teardown
cp /opt/scripts/disable_trace.sh ${yardstick_prefix}
echo "verifying the copied file"
ls ${yardstick_prefix}
( cd /root/yardstick ; pip install -U . )


#setting up of image for launching guest vm.
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
root@$HOST_IP "cp /root/images/guest1.qcow2 /root/"

#Updating the yardstick.conf file for daily
function updateConfDaily() {
   DISPATCHER_TYPE=influxdb
   DISPATCHER_FILE_NAME="/tmp/yardstick.out"
   # Use the influxDB on the jumping server
   DISPATCHER_INFLUXDB_TARGET="http://104.197.68.199:8086"
   mkdir -p /etc/yardstick
   cat << EOF > /etc/yardstick/yardstick.conf
[DEFAULT]
debug = True
dispatcher = ${DISPATCHER_TYPE}

[dispatcher_file]
file_name = ${DISPATCHER_FILE_NAME}

[dispatcher_influxdb]
timeout = 5
db_name = yardstick
username = opnfv
password = 0pnfv2015
target = ${DISPATCHER_INFLUXDB_TARGET}
EOF
}

#Function call to update yardstick conf file based on Job type
if [ "$testType" == "daily" ];then
   updateConfDaily
fi

#Running cyclictest through yardstick
yardstick -d task start ${cyclictest_context_file}
output=$?

if [ "$testType" == "verify" ];then
   chmod 777 /tmp/yardstick.out
   cat /tmp/yardstick.out  > /opt/yardstick.out
fi

if [ $output != 0 ];then
   echo "Yardstick Failed !!!"
   exit 1
fi

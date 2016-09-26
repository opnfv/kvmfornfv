#!/bin/bash

###########################################################
## Invoking this script from ubuntu docker container runs
## cyclictest through yardstick
###########################################################
source utils.sh

testType=$1 #daily/verify/merge
HOST_IP=$( getHostIP )
pod_config='/opt/scripts/pod.yaml'
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

#Updating the yardstick.conf file for daily
function updateConfDaily() {
   DISPATCHER_TYPE=influxdb
   DISPATCHER_FILE_NAME="/tmp/yardstick.out"
   # Use the influxDB on the jumping server
   DISPATCHER_INFLUXDB_TARGET="http://10.2.117.21:8086"
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
username = root
password = root
target = ${DISPATCHER_INFLUXDB_TARGET}
EOF
}

#Function call to update yardstick conf file based on Job type
#if [ "$testType" == "daily" ];then
updateConfDaily
#fi

#Running cyclictest through yardstick
yardstick -d task start ${cyclictest_context_file}
output=$?

#   chmod 777 /tmp/yardstick.out
#    cat /tmp/yardstick.out  > /opt/yardstick.out

if [ $output != 0 ];then
   echo "Someproblem with execution of Yardstick"
   exit 1
fi

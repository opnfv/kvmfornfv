#!/bin/bash

###########################################################
## Invoking this script from ubuntu docker container runs
## cyclictest through yardstick
###########################################################
source utils.sh

testType=$1 #daily/verify/merge
HOST_IP=$( getHostIP )
pod_config='/opt/scripts/pod.yaml'
cyclictest_idle_idle='/opt/kvmfornfv_cyclictest_idle_idle.yaml'

if [ ! -f ${pod_config} ] ; then
    echo "file ${pod_config} not found"
    exit 1
fi

if [ ! -f ${cyclictest_idle_idle} ] ; then
    echo "file ${cyclictest_idle_idle} not found"
    exit 1
fi

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

function runYardstick() {
   file_name=$1
    #Running cyclictest through yardstick
   yardstick -d task start ${file_name}
   local status=$?
   if [ $status -ne 0 ]; then
      echo "yardstick failed with $file_name" >&2
      exit 1
    fi
    return $status
}

#Function call to update yardstick conf file based on Job type
if [ "$testType" == "daily" ];then
   updateConfDaily
   runYardstick ${cyclictest_idle_idle}
   cyclictest_cpustress_idle='/opt/kvmfornfv_cyclictest_cpustress_idle.yaml'
   if [ -f ${cyclictest_cpustress_idle} ] ; then
      runYardstick ${cyclictest_cpustress_idle}
   fi
else
#   runYardstick ${cyclictest_idle_idle} 
   cyclictest_cpustress_idle='/opt/kvmfornfv_cyclictest_cpustress_idle.yaml'
   runYardstick ${cyclictest_cpustress_idle}
   chmod 777 /tmp/yardstick.out
   cat /tmp/yardstick.out  > /opt/yardstick.out
fi

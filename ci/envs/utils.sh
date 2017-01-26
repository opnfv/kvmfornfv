#!/bin/bash
###############################################################################
#      This script is to fetch kernel version and host ip at run time.
###############################################################################

#To get the Kernel version from RPM generated(example:kernel-4.4.6_rt14_1607061504nfv-3.x86_64.rpm)
function getKernelVersion {
   rpm_dir="/root/workspace/rpm/"
   if [ -d "$WORKSPACE" ];then
      cd $WORKSPACE/build_output 2>/dev/null; kernelRPM=`ls kernel-[[:digit:]]* 2>/dev/null`
      RPMVERSION=`echo ${kernelRPM}|awk -F '_' '{print $1}' | awk -F '-' '{print $NF}'`
   elif [ -d "$rpm_dir" ];then
      cd $rpm_dir 2>/dev/null; kernelRPM=`ls kernel-[[:digit:]]* 2>/dev/null`
      RPMVERSION=`echo ${kernelRPM}|awk -F '_' '{print $1}' | awk -F '-' '{print $NF}'`
   fi
   echo ${RPMVERSION}
}

#Get the IP address from pod.yaml file (example ip : 10.10.100.22)
function getHostIP {
   host_dir="/root/workspace/scripts/"
   container_dir="/opt/scripts/"
   if [ -d "$container_dir" ];then
      HOST_IP=`grep 'ip' $container_dir/pod.yaml | awk -F ': ' '{print $NF}' | tail -1`
   elif [ -d "$host_dir" ];then
      HOST_IP=`grep 'ip' $host_dir/pod.yaml | awk -F ': ' '{print $NF}' | tail -1`
   fi
   echo $HOST_IP
}

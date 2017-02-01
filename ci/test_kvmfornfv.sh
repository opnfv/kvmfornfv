#!/bin/bash

############################################################
## This script  is an interface to trigger the
## cyclicTestTrigger.sh for test type like patch verification,
## daily testing.
## Releng will trigger this script by passing test type as
## verify/daily and test name as idle_idle/stress_idle/
## packet_forward as arguments.
## Verify Job runs idle_idle,packet_forward test
## daily job runs base on the test name parameter
############################################################

test_type=$1
test_name=$2
cyclictest_env_verify=("idle_idle" "cpustress_idle" "memorystress_idle" "iostress_idle") #cyclictest environment
cyclictest_env_daily=("idle_idle" "cpustress_idle" "memorystress_idle" "iostress_idle")
cyclictest_result=0 #exit code of cyclictest
packetforward_result=0 #exit code of packet forward

function packetForward {
#   source $WORKSPACE/ci/packet_forward_test.sh $HOST_IP
   echo "Packetforwarding need to be implemented"
   packetforward_result=$?
   if [ ${packetforward_result} -ne 0 ];then
      echo "Packet Forwarding test case execution FAILED"
   else
      echo "Packet Forwarding test case executed SUCCESSFULLY"
   fi
   host_clean
}

function cyclictest {
   test_case=$1
   source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type $test_case
   #calculating and verifying sha512sum of the guestimage.
   if ! verifyGuestImage;then
      exit 1
   fi
   #Update kvmfornfv_cyclictest_${testName}.yaml with test_time and pod.yaml with IP
   updateYaml
   #Cleaning up the test environment before running cyclictest through yardstick.
   env_clean
   #Creating a docker image with yardstick installed and launching ubuntu docker to run yardstick cyclic testcase
   if runCyclicTest;then
      cyclictest_result=`expr ${cyclictest_result} + 0`
   else
      echo "Test case execution FAILED for ${test_case} environment"
      cyclictest_result=`expr ${cyclictest_result} + 1`
   fi
}

function collect_MBWInfo {
   #Collecting the Memory Bandwidth Information using pcm-memory utility
   source $WORKSPACE/ci/envs/host-config
   testState=$1
   testType=$2
   timeStamp=$(date +%Y%m%d%H%M%S)
   mkdir -p $WORKSPACE/build_ouput/log/MBWInfo
   sudo ssh root@${HOST_IP} "mkdir -p /root/MBWInfo"
   if [ ${testState} == "beforeTest" ];then
   sudo ssh root@${HOST_IP} "timeout 10 ${pcm_memory} 2 > /root/MBWInfo/MBWInfo_${testState}_${timeStamp}_${testType}"
   #Copying Log files from Node to Jump server
   else
   sudo ssh root@${HOST_IP} "cd /tmp;file=\${`ls -rt | grep MBWInfo`}; mv /tmp/${file} /root/MBWInfo/${file}_${testType}"
   fi
   #Copying MBW logs from Node server to Jump Server
   scp root@${HOST_IP}:/root/MBWInfo/MBWInfo* $WORKSPACE/build_output/log/MBWInfo/
   sudo ssh root@${HOST_IP} "cd /root/MBWInfo;rm MBWInfo*"
   sudo ssh root@${HOST_IP} "pid=\$(ps aux | grep 'pcm' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"
}
    
function install_pcm {
   source $WORKSPACE/ci/envs/host-config
   sudo ssh root@${HOST_IP} '
   modelName=`cat /proc/cpuinfo | grep -i "model name" | uniq`
   if  echo "$modelName" | grep -i "xeon" ;then
   echo  "pcm utility supports $modelName processor"
   else
   echo "check for the pcm utility supported processors"
   exit 1
   fi
   cd /root
   if [ ! -d "pcm" ]; then
    `git clone https://github.com/opcm/pcm` 
     cd pcm
     make
   fi
   echo "Disabling NMI Watchdog"  
   echo 0 > /proc/sys/kernel/nmi_watchdog
   echo "To Access MSR registers installing msr-tools"
   sudo yum install msr-tools
   sudo modprobe msr
   '
}
#Execution of testcases based on test type and test name from releng.
if [ ${test_type} == "verify" ];then
   HOST_IP="10.2.117.23"
   test_time=120000 # 2m
   install_pcm
   collect_MBUInfo beforeTest ${test_type}
   for env in ${cyclictest_env_verify[@]}
   do
      #Executing cyclictest through yardstick.
      cyclictest ${env}
      collect_MBUInfo afterTest ${test_type}
      sleep 10
   done
   #Execution of packet forwarding test cases.
   packetForward
   if [ ${cyclictest_result} -ne 0 ] ||  [ ${packetforward_result} -ne 0 ];then
      echo "Test case FAILED"
      exit 1
   else
      exit 0
   fi
elif [ ${test_type} == "daily" ];then
   HOST_IP="10.2.117.25"
   test_time=3600000 #1h
   install_pcm
   collect_MBUInfo beforeTest ${test_type}
   if [ ${test_name} == "packet_forward" ];then
      packetForward
      if [ ${packetforward_result} -ne 0 ] ; then
         exit 1
      else
         exit 0
      fi
   elif [ ${test_name} == "cyclictest" ];then
      for env in ${cyclictest_env_daily[@]}
      do
         #Executing cyclictest through yardstick.
         cyclictest ${env}
         collect_MBUInfo afterTest ${test_type}
         sleep 5
      done
      if [ ${cyclictest_result} -ne 0 ] ; then
         echo "Cyclictest case execution FAILED"
         exit 1
      else
         echo "Cyclictest case executed SUCCESSFULLY"
         exit 0
      fi
   fi
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
else
   echo "Incorrect test type ${test_type}"
fi

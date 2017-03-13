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
ftrace_enable=0
cyclictest_env_verify=("idle_idle" "cpustress_idle" "memorystress_idle" "iostress_idle") #cyclictest environment
cyclictest_env_daily=("idle_idle" "cpustress_idle" "memorystress_idle" "iostress_idle")
cyclictest_result=0 #exit code of cyclictest
packetforward_result=0 #exit code of packet forward
source $WORKSPACE/ci/envs/host-config

function packetForward {
#   source $WORKSPACE/ci/packet_forward_test.sh $HOST_IP
   echo "Packetforwarding need to be implemented"
   packetforward_result=$?
   if [ ${packetforward_result} -ne 0 ];then
      echo "Packet Forwarding test case execution FAILED"
   else
      echo "Packet Forwarding test case executed SUCCESSFULLY"
   fi
}

function cyclictest {
   test_case=$1
   source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type $test_case
   #Verifying whether the test node is up and running
   connect_host
   #Waiting for ssh to be available for the host machine.
   sleep 20
   #calculating and verifying sha512sum of the guestimage.
   if ! verifyGuestImage;then
      exit 1
   fi
   #Update kvmfornfv_cyclictest_${testName}.yaml with test_time and pod.yaml with IP
   updateYaml
   #Running PCM utility
   collect_MBWInfo $test_type
   #Checking which test cases will be executed first and last from the list to perform cleaning operations.
   first_test_case=cyclictest_env_$test_type[0]
   last_test_case=cyclictest_env_$test_type[-1]
   #Cleaning the environment before running cyclictest through yardstick
   if [ ${test_case} == "${!first_test_case}" ];then
      env_clean
   else
      sudo ssh root@${HOST_IP} "pid=\$(ps aux | grep 'qemu' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"
   fi
   #Creating a docker image with yardstick installed and launching ubuntu docker to run yardstick cyclic testcase
   if runCyclicTest;then
      cyclictest_result=`expr ${cyclictest_result} + 0`
   else
      echo "Test case execution FAILED for ${test_case} environment"
      cyclictest_result=`expr ${cyclictest_result} + 1`
   fi
   echo "Terminating PCM Process"
   sudo ssh root@${HOST_IP} "pid=\$(ps aux | grep 'pcm' | awk '{print \$2}' | head -1); echo \$pid |xargs kill -SIGTERM"
   if [ ${test_case} != "${!last_test_case}" ];then
      sudo ssh root@${HOST_IP} "reboot"
   fi
}
function collect_MBWInfo {
   #Collecting the Memory Bandwidth Information using pcm-memory utility
   source $WORKSPACE/ci/envs/host-config
   testType=$1
   timeStamp=$(date +%Y%m%d%H%M%S)
   echo "Running PCM memory to collect memory bandwidth"
   sudo ssh root@${HOST_IP} "mkdir -p /root/MBWInfo"
   sudo ssh root@${HOST_IP} "${pcm_memory} 60 &>/root/MBWInfo/MBWInfo_${testType}_${timeStamp} &disown"
}
function install_pcm {
   source $WORKSPACE/ci/envs/host-config
   sudo ssh root@${HOST_IP} '
   modelName=`cat /proc/cpuinfo | grep -i "model name" | uniq`
   if echo "$modelName" | grep -i "xeon" ;then
      echo "pcm utility supports $modelName processor"
   else
      echo "check for the pcm utility supported processors"
      exit 1
   fi
   cd /root
   if [ ! -d "pcm" ]; then
     `git clone https://github.com/opcm/pcm`
      cd pcm
      make
      echo "Disabling NMI Watchdog"
      echo 0 > /proc/sys/kernel/nmi_watchdog
      echo "To Access MSR registers installing msr-tools"
      sudo yum install msr-tools
      sudo modprobe msr
   fi
   '
}

function ftrace_disable {
   sudo ssh root@${HOST_IP} "sh /root/workspace/scripts/disbale-trace.sh"
   sudo ssh root@${HOST_IP} "cd /tmp ; a=\$(ls -rt | tail -1) ; echo \$a ; mv \$a cyclictest_${env}.txt"
   sudo mkdir -p $WORKSPACE/build_output/log/kernel_trace
   sudo scp root@${HOST_IP}:/tmp/cyclictest_${env}.txt $WORKSPACE/build_output/log/kernel_trace/
}

#Execution of testcases based on test type and test name from releng.
if [ ${test_type} == "verify" ];then
   HOST_IP="10.10.100.21"
   test_time=1000 # 1s
   install_pcm
   if [ ${ftrace_enable} -eq '1' ]; then
      for env in ${cyclictest_env_verify[@]}
      do
         #Enabling ftrace for kernel debugging.
         sed -i '/host-setup1.sh/a\    \- \"enable-trace.sh\"' kvmfornfv_cyclictest_hostenv_guestenv.yaml
         #Executing cyclictest through yardstick.
         cyclictest ${env}
         #disabling ftrace and collecting the logs to upload to artifact repository.
         ftrace_disable
         sleep 10
      done
      #Execution of packet forwarding test cases.
      packetForward
   else
      for env in ${cyclictest_env_verify[@]}
      do
         #Executing cyclictest through yardstick.
         cyclictest ${env}
         sleep 10
      done
      env_clean
      host_clean
      #Execution of packet forwarding test cases.
      packetForward
   fi
      if [ ${cyclictest_result} -ne 0 ] ||  [ ${packetforward_result} -ne 0 ];then
         echo "Test case FAILED"
         test_exit 1
      else
         test_exit 0
      fi
elif [ ${test_type} == "daily" ];then
   HOST_IP="10.10.100.22"
   test_time=3600000 #1h
   install_pcm
   if [ ${test_name} == "packet_forward" ];then
      packetForward
      if [ ${packetforward_result} -ne 0 ] ; then
         test_exit 1
      else
         test_exit 0
      fi
   elif [ ${test_name} == "cyclictest" ];then
      if [ ${ftrace_enable} -eq '1' ]; then
         for env in ${cyclictest_env_daily[@]}
         do
            #Enabling ftrace for kernel debugging.
            sed -i '/host-setup1.sh/a\    \- \"enable-trace.sh\"' kvmfornfv_cyclictest_hostenv_guestenv.yaml
            #Executing cyclictest through yardstick.
            cyclictest ${env}
            #disabling ftrace and collecting the logs to upload to artifact repository. 
            ftrace_disable
            sleep 5
         done
      else
         for env in ${cyclictest_env_daily[@]}
         do
         #Executing cyclictest through yardstick.
         cyclictest ${env}
         sleep 5
         done
         env_clean
         host_clean
      fi
         if [ ${cyclictest_result} -ne 0 ] ; then
            echo "Cyclictest case execution FAILED"
            test_exit 1
         else
            echo "Cyclictest case executed SUCCESSFULLY"
            test_exit 0
         fi
   fi
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
else
   echo "Incorrect test type ${test_type}"
fi

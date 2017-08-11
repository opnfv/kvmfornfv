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
cyclictest_env_verify=("idle_idle" "memorystress_idle") #cyclictest environment
cyclictest_env_daily=("idle_idle" "cpustress_idle" "memorystress_idle" "iostress_idle")
cyclictest_result=0 #exit code of cyclictest
packetforward_result=0 #exit code of packet forward
lm_env_verify=("peer-peer" "local")
source $WORKSPACE/ci/envs/host-config

#check if any kernel rpms available for testing
rpm_count=`ls -1 $WORKSPACE/build_output/*.rpm 2>/dev/null | wc -l`
if [ $rpm_count = 0 ];then
   echo "This patch is used for building kernel debian packages required by compass installer and \
the test environment for testing debain packages is not available"
   exit 0
fi

function packetForward {
   #executing packet forwarding test cases based on the job type.
   if [ ${test_type} == "verify" ];then
      echo "packet forwarding test cases are not yet implemented for verify job"
      packetforward_result=0
   elif [ ${test_type} == "daily" ];then
      source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP
      connect_host
      #Waiting for ssh to be available for the host machine.
      sleep 20
      # copy files and rpms and setup environment required for executing test cases
      setUpPacketForwarding
      sleep 1
      #Verifying whether the test node is up and running
      connect_host
      sleep 20
      #Install and Execute packet forwarding test cases
      runPacketForwarding $test_type
      packetforward_result=$?
   else
      echo "Incorrect test type ${test_type}"
      exit 1
   fi
}
function liveMigration {
   #executing live migration test case on the host machine
   test_env=$1
   echo "Test Environment ${test_env}"
   if [ ${test_env} == "peer-peer" ];then
      echo "live migration is not implemented for peer to peer"
      livemigration_result=0
   elif [ ${test_env} == "local" ];then
      source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP
      connect_host
      #Waiting for ssh to be available for the host machine.
      sleep 20
      runLiveMigration ${test_env}
      livemigration_result=$?
   else
      echo "Incorrect test environment for live migration"
      exit 1
   fi
}

function getTestParams {
   HOST_IP=$( setHostIP $test_type )
   test_time=$( setTestTime $test_type )
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
   #Cleaning the environment before running cyclictest through yardstick
   env_clean
   #Creating a docker image with yardstick installed and launching ubuntu docker to run yardstick cyclic testcase
   if runCyclicTest ${ftrace_enable};then
      cyclictest_result=`expr ${cyclictest_result} + 0`
   else
      echo "Test case execution FAILED for ${test_case} environment"
      cyclictest_result=`expr ${cyclictest_result} + 1`
   fi
   echo "Terminating PCM Process"
   sudo ssh root@${HOST_IP} "pid=\$(ps aux | grep 'pcm' | awk '{print \$2}' | head -1); echo \$pid |xargs kill -SIGTERM"
}
#Collecting the Memory Bandwidth Information using pcm-memory utility
function collect_MBWInfo {
   testType=$1
   timeStamp=$(date +%Y%m%d%H%M%S)
   echo "Running PCM memory to collect memory bandwidth"
   sudo ssh root@${HOST_IP} "mkdir -p /root/MBWInfo"
   sudo ssh root@${HOST_IP} "${pcm_memory} 60 &>/root/MBWInfo/MBWInfo_${testType}_${timeStamp} &disown"
}
function install_pcm {
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

#Execution of testcases based on test type and test name from releng.
if [ ${test_type} == "verify" ];then
   getTestParams
   install_pcm
   if [ ${ftrace_enable} -eq '1' ]; then
      for env in ${cyclictest_env_verify[@]}
      do
         #Enabling ftrace for kernel debugging.
         sed -i '/host-setup1.sh/a\    \- \"enable-trace.sh\"' $WORKSPACE/tests/kvmfornfv_cyclictest_hostenv_guestenv.yaml
         #Executing cyclictest through yardstick.
         cyclictest ${env}
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
      #Execution of packet forwarding test cases.
      packetForward
      for envi in ${lm_env_verify[@]}
      do
         echo "Executing Live Migration on the node"
         liveMigration ${envi}
      done
   fi
   if [ ${cyclictest_result} -ne 0 ] ||  [ ${packetforward_result} -ne 0 ];then
      echo "Test case FAILED"
      test_exit 1
   else
      test_exit 0
   fi
elif [ ${test_type} == "daily" ];then
   getTestParams
   install_pcm
   if [ ${test_name} == "packet_forward" ];then
      packetForward
      packet_fwd_logs
      #clean the test environment after the test case execution.
      sudo ssh root@${HOST_IP} "rm -rf /root/workspace/*"
      host_clean
      if [ ${packetforward_result} -ne 0 ] ; then
         echo "Execution of packet forwarding test cases FAILED"
         packet_fwd_exit 1
      else
         echo "Executed packet forwarding test cases SUCCESSFULLY"
         packet_fwd_exit 0
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
      fi
         if [ ${cyclictest_result} -ne 0 ] ; then
            echo "Cyclictest case execution FAILED"
            test_exit 1
         else
            echo "Cyclictest case executed SUCCESSFULLY"
            test_exit 0
         fi
   elif [ ${test_name} == "livemigration" ];then
         for envi in ${lm_env_verify[@]}
         do
         echo "Executing Live Migration on the node"
         liveMigration ${envi}
         done
         sudo ssh root@${HOST_IP} "rm -rf /root/workspace/*"
         host_clean
         if [ ${livemigration_result} -ne 0 ] ; then
            echo "livemigration test case execution FAILED"
            test_exit 1
         else
            echo "livemigration test case executed SUCCESSFULLY"
            test_exit 0
         fi
   fi
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
else
   echo "Incorrect test type ${test_type}"
fi

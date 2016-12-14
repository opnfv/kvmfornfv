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
   env_clean
   host_clean
}

function cyclictest {
   test_case=$1
   source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type $test_case
   #Update kvmfornfv_cyclictest_${testName}.yaml with test_time and pod.yaml with IP
   updateYaml
   #Cleaning up the test environment before running cyclictest through yardstick.
   if [ ${test_case} == "idle_idle" ];then
   env_clean
   fi
   #Creating a docker image with yardstick installed and launching ubuntu docker to run yardstick cyclic testcase
   if runCyclicTest;then
      cyclictest_result=`expr ${cyclictest_result} + 0`
   else
      echo "Test case execution FAILED for ${test_case} environment"
      cyclictest_result=`expr ${cyclictest_result} + 1`
   fi
}

function dockerImageBuild {
   docker_image_dir=$WORKSPACE/docker_image_build
   ( cd ${docker_image_dir}; sudo docker build  -t kvmfornfv:latest --no-cache=true . )
   if [ ${?} -ne 0 ] ; then
      echo  "Docker image build failed"
      id=$(sudo docker ps -a  | head  -2 | tail -1 | awk '{print $1}'); sudo docker rm -f $id
      exit 1
   fi
}


#Execution of testcases based on test type and test name from releng.
if [ ${test_type} == "verify" ];then
   HOST_IP="10.2.117.23"
   test_time=120000 # 2m
   source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type
   #calculating and verifying sha512sum of the guestimage.
   if ! verifyGuestImage;then
      exit 1
   fi
   dockerImageBuild
   for env in ${cyclictest_env_verify[@]}
   do
      #Executing cyclictest through yardstick.
      cyclictest ${env}
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
   if [ ${test_name} == "packet_forward" ];then
      packetForward
      if [ ${packetforward_result} -ne 0 ] ; then
         exit 1
      else
         exit 0
      fi
   elif [ ${test_name} == "cyclictest" ];then
      source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type
+      #calculating and verifying sha512sum of the guestimage.
+      if ! verifyGuestImage;then
+         exit 1
+      fi
+      dockerImageBuild
      for env in ${cyclictest_env_daily[@]}
      do
         #Executing cyclictest through yardstick.
         cyclictest ${env}
         sleep 5
      done
      if [ ${cyclictest_result} -ne 0 ] ; then
         echo "Cyclictest case execution FAILED"
         exit 1
      else
         echo "Cyclictest case executed SUCCESSFULLY"
         exit 0
      fi
      env_clean
+     host_clean
   fi
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
else
   echo "Incorrect test type ${test_type}"
fi

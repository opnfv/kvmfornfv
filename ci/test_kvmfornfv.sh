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

function packetForward {
   source $WORKSPACE/ci/packet_forward_test.sh $HOST_IP
   packetforward_result=$?
   host_clean
}

function cyclictest {
   test_name=$1
   source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type $test_name
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
      cyclictest_result=0
   else
      cyclictest_result=1
   fi
}

if [ ${test_type} == "verify" ];then
   HOST_IP="10.2.117.23"
   test_time=600000 # 10m
   test_name="idle_idle"
   cyclictest ${test_name}
   sleep 10
   packetForward
   if [ ${cyclictest_result} -ne 0 ] ||  [ ${packetforward_result} -ne 0 ];then
      echo "Test case execution FAILED"
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
         echo "Packet Forwarding test case execution FAILED"
         exit 1
      else
         echo "Packet Forwarding test case executed SUCCESSFULLY"
         exit 0
      fi
   elif [ ${test_name} == "idle_idle" ] || [ ${test_name} == "stress_idle" ];then
      cyclictest ${test_name}
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
   exit 1
fi

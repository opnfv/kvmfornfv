#!/bin/bash

############################################################
## This script  is an interface to trigger the
## cyclicTestTrigger.sh for test type like patch verification,
## daily testing.
## Releng will trigger this script by passing test type like
## verify/daily as an argument
############################################################

test_type=$1
#test_name=$2 Need to uncomment this once jjb is updated
if [ ${test_type} == "verify" ];then
   HOST_IP="10.2.117.23"
   test_time=600000 # 10m
   test_name="idle_idle"
elif [ ${test_type} == "daily" ];then
   HOST_IP="10.2.117.25"
   test_time=3600000 #1h
   test_name="stress_idle"
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
else
   echo "Incorrect test type ${test_type}"
   exit 1
fi

if [ ${test_name} == "packet_forward" ];then
   echo "pkt forwarding script name "
else
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
      exit 0
   else
      exit 1
   fi
fi

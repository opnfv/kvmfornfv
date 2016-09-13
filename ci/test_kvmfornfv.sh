#!/bin/bash

############################################################
## This script  is an interface to trigger the
## cyclicTestTrigger.sh for test type like patch verification,
## daily testing.
## Releng will trigger this script by passing test type like
## verify/daily as an argument
############################################################

test_type=$1

if [ ${test_type} == "verify" ];then
   HOST_IP="10.2.117.23"
   test_time=600000 # 10m
elif [ ${test_type} == "daily" ];then
   HOST_IP="10.2.117.25"
   test_time=7200000 #2h
elif [ ${test_type} == "merge" ];then
   echo "Test is not enabled for ${test_type}"
   exit 0
fi

source $WORKSPACE/ci/cyclicTestTrigger.sh $HOST_IP $test_time $test_type

#Update cyclictest-node-context.yaml with test_time and pod.yaml with IP
updateYaml

#Cleaning up the test environment before running cyclictest through yardstick.
env_clean

#Creating a docker image with yardstick installed and launching ubuntu docker to run yardstick cyclic testcase
runCyclicTest

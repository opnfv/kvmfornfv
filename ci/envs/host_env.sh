#!/bin/bash
###############################################################################
#      This is a host environment configuration script to set host ip,
#      test duration etc., based on the job type. 
#      Example for verification job : 10.10.100.21 
###############################################################################

#Host for executing test cases based on test_type/job from releng
function setHostIP {
   test_type=$1
   if [ ${test_type} == "verify" ];then
      HOST_IP="10.10.100.21"
   elif [ ${test_type} == "daily" ];then
      HOST_IP="10.10.100.22"
   else
      echo "Incorrect test type"
   fi
   echo ${HOST_IP}
}

#Time duration for executing test cases based on test_type/job from releng
function setTestTime {
   test_type=$1
   if [ ${test_type} == "verify" ];then
      test_time=120000 # 2m
   elif [ ${test_type} == "daily" ];then
      test_time=3600000 # 1hr
   else
      echo "Incorrect test type"
   fi
   echo ${test_time}
}

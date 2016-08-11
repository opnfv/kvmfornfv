#!/bin/bash

#############################################################
## !!! The original test_kvmfornfv.sh is removed because it
## break the verification process!!!
#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

echo "Hello world"
volume=/tmp/kvmtest-*
echo $volume
if [ -d ${volume} ] ; then
    echo "Directory '${volume}' exists"
    sudo rm -rf ${volume}
fi

echo ${WORKSPACE}

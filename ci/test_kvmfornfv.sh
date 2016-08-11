#!/bin/bash

#############################################################
## !!! The original test_kvmfornfv.sh is removed because it
## break the verification process!!!
#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

time_stamp=$(date +%Y%m%d%H%M%S)
volume=/tmp/kvmtest-${time_stamp}
mkdir -p $volume/{image,rpm,scripts}
echo $volume

#copying required files to run yardstick cyclic testcase
mv $WORKSPACE/build_output/kernel-4.4*.rpm $volume/rpm
cp -r $WORKSPACE/ci/envs/* $volume/scripts
ls -al $volume/scripts
cp -r $WORKSPACE/tests/cyclictest-node-context.yaml $volume
cp -r $WORKSPACE/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -i -v $volume:/opt --net=host --name kvmfornfv1 \
kvmfornfv:latest  /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh"
ls $volume
container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'`
sudo docker rm $container_id
sudo rm -rf /tmp/kvmtest-*


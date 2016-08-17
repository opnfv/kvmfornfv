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

#copying required files to run yardstick cyclic testcase
mv $WORKSPACE/build_output/kernel-4.4*.rpm $volume/rpm
cp -r $WORKSPACE/ci/envs/* $volume/scripts
cp -r $WORKSPACE/tests/cyclictest-node-context.yaml $volume
cp -r $WORKSPACE/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -i -v $volume:/opt --net=host --name kvmfornfv \
kvmfornfv:latest  /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh"
container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'`
sudo docker rm $container_id

#Verifying the results of cyclictest
result=`grep -o '"errors":[^,]*' $volume/yardstick.out | awk -F '"' '{print $4}'`

if [ -z "$result" ]; then
    echo "####################################################"
    echo ""
    echo `grep -o '"data":[^}]*' $volume/yardstick.out | awk -F '{' '{print $2}'`
    echo ""
    echo "####################################################"
    exit 0
else
    echo "Testcase failed"
    echo `grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`
    exit 1
fi

sudo rm -rf /tmp/kvmtest-*
ssh 10.2.117.23 "rm -rf /root/workspace/*"
ssh 10.2.117.23 "pid=\$(ps aux | grep 'qemu' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"

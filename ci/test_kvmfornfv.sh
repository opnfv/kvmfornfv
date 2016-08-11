#!/bin/bash

#############################################################
## !!! The original test_kvmfornfv.sh is removed because it
## break the verification process!!!
#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

volume=/tmp/kvmtest-*
echo $volume
if [ -d ${volume} ] ; then
    echo "Directory '${volume}' exists"
    sudo rm -rf ${volume}
fi

echo ${WORKSPACE}
time_stamp=$(date +%Y%m%d%H%M%S)
mkdir -p /tmp/kvmtest-${time_stamp}/{image,rpm,scripts}
echo $volume

#copying required files to run yardstick cyclic testcase
mv $WORKSPACE/build_output/* $volume/rpm
cp -r $WORKSPACE/ci/envs/* $volume/scripts
ls -al $volume/scripts
cp -r $WORKSPACE/tests/cyclictest-node-context.yaml $volume
cp -r $WORKSPACE/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -i -v $volume:/opt --net=host --name kvmfornfv \
kvmfornfv:latest  /bin/bash -c "/opt/scripts/cyclictest.sh"
container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'`
sudo docker rm $container_id
sudo rm -rf /tmp/kvmtest-*

#Verifying the results of cyclictest
result=`grep -o '"errors":[^,]*' $volume/yardstick.out | awk -F '"' \
'{print $4}'| awk '{if (NF=0) print "SUCCESS" }'`
if [ "$result" = "SUCCESS" ]; then
    echo "####################################################"
    echo ""
    echo `grep -o '"data":[^}]*' $volume/yardstick.out | awk -F '{' '{print $2}'`
    echo ""
    echo "####################################################"
    exit 0
else
    echo "Testcase failed"
    echo `grep -o '"errors":[^,]*' $volume/yardstick.out | awk -F '"' '{print $4}'`
    exit 1
fi

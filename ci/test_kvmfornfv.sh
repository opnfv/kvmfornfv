#!/bin/bash

#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

volume=/root/local_workspace
if [ -d ${volume} ] ; then
    echo "Directory '${volume}' exists"
    sudo rm -rf ${volume}
fi

mkdir -p /root/local_workspace/{image,rpm,scripts}

#copying required files to run yardstick cyclic testcase
mv ${WORKSPACE}/build_output/* $volume/rpm
cp ${WORKSPACE}/ci/envs/* $volume/scripts
cp ${WORKSPACE}/tests/cyclictest-node-context.yaml $volume
cp ${WORKSPACE}/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -t -i -v $volume:/opt --net=host --name kvmfornfv \
kvmfornfv:latest  /bin/bash /opt/scripts/cyclictest.sh
container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'`
sudo docker rm $container_id

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

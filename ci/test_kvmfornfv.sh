#!/bin/bash

#############################################################
## !!! The original test_kvmfornfv.sh is removed because it
## break the verification process!!!
#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

echo ${WORKSPACE}
time_stamp=$(date +%Y%m%d%H%M%S)
volume=/tmp/kvmtest-${time_stamp}
mkdir -p $volume/{image,rpm,scripts}
echo $volume

#copying required files to run yardstick cyclic testcase
mv $WORKSPACE/build_output/* $volume/rpm
cp -r $WORKSPACE/ci/envs/* $volume/scripts
ls -al $volume/scripts
cp -r $WORKSPACE/tests/cyclictest-node-context.yaml $volume
cp -r $WORKSPACE/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -i -v $volume:/opt --net=host --name kvmfornfv1 \
kvmfornfv:latest  /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh"
container_id=`sudo docker ps -a | grep kvmfornfv1 |awk '{print $1}'`
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

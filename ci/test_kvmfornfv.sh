#!/bin/bash

#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

docker_image_dir=$WORKSPACE/docker_image_build
function env_clean {
    container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'`
    sudo docker rm $container_id
    sudo ssh root@10.2.117.23 "rm -rf /root/workspace/*"
    sudo ssh root@10.2.117.23 "pid=\$(ps aux | grep 'qemu' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"
    sudo rm -rf /tmp/kvmtest-*
}

#Cleaning up the test environment before running cyclictest through yardstick.
env_clean

#Creating a docker image with yardstick installed.
( cd ${docker_image_dir}; sudo docker build  -t kvmfornfv:latest --no-cache=true . )
if [ ${?} -ne 0 ] ; then
    echo  "Docker image build failed"
    id=$(sudo docker ps -a  | head  -2 | tail -1 | awk '{print $1}'); sudo docker rm -f $id
    exit 1
fi

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

#Verifying the results of cyclictest
result=`grep -o '"errors":[^,]*' $volume/yardstick.out | awk -F '"' '{print $4}'`

if [ -z "$result" ]; then
    echo "####################################################"
    echo ""
    echo `grep -o '"data":[^}]*' $volume/yardstick.out | awk -F '{' '{print $2}'`
    echo ""
    echo "####################################################"
    env_clean
    exit 0
else
    echo "Testcase failed"
    echo `grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`
    env_clean
    exit 1
fi

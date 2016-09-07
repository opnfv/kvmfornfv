#!/bin/bash

#############################################################
## This script  will launch ubuntu docker container
## runs cyclictest through yardstick
## and verifies the test results.
############################################################

source $WORKSPACE/ci/envs/utils.sh
pod_config='$WORKSPACE/tests/pod.yaml'
if [ ! -f ${pod_config} ] ; then
    echo "file ${pod_config} not found"
    exit 1
else
    HOST_IP=$( getHostIP )
fi

KERNEL_VERSION=$( getKernelVersion )
if [ -z $KERNEL_VERSION ];then
   echo "Kernel RPM not found in $WORKSPACE/build_output Directory"
   exit 1
fi

docker_image_dir=$WORKSPACE/docker_image_build
function env_clean {
    container_id=`sudo docker ps -a | grep kvmfornfv |awk '{print $1}'|sed -e 's/\r//g'`
    sudo docker rm $container_id
    sudo ssh root@$HOST_IP "rm -rf /root/workspace/*"
    sudo ssh root@$HOST_IP "pid=\$(ps aux | grep 'qemu' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"
    sudo rm -rf /tmp/kvmtest-*
}

function host_clean {
    sudo ssh root@$HOST_IP "rpm=\$(rpm -qa | grep 'kernel-${KERNEL_VERSION}' | awk '{print \$1}'); rpm -ev \$rpm"
    sudo ssh root@$HOST_IP "rm -rf /boot/initramfs-${KERNEL_VERSION}*.img"
    sudo ssh root@$HOST_IP "grub2-mkconfig -o /boot/grub2/grub.cfg"
    sudo ssh root@$HOST_IP "reboot"
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
mv $WORKSPACE/build_output/kernel-${KERNEL_VERSION}*.rpm $volume/rpm
cp -r $WORKSPACE/ci/envs/* $volume/scripts
cp -r $WORKSPACE/tests/cyclictest-node-context.yaml $volume
cp -r $WORKSPACE/tests/pod.yaml $volume

#Launching ubuntu docker container to run yardstick
sudo docker run -i -v $volume:/opt --net=host --name kvmfornfv \
kvmfornfv:latest  /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh"

#Cleaning the latest kernel changes on host after executing the test.
host_clean

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

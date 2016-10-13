#!/bin/bash

#############################################################
## This script defines the functions present in
## test_kvmfornfv.sh interface.These will launch ubuntu
## docker container runs cyclictest through yardstick
## and verifies the test results.
############################################################

HOST_IP=$1
testTime=$2
testType=$3

source $WORKSPACE/ci/envs/utils.sh
KERNELRPM_VERSION=$( getKernelVersion )

if [ -z ${KERNELRPM_VERSION} ];then
   echo "Kernel RPM not found in build_output Directory"
   exit 1
fi

#calculating and verifying sha512sum of the guestimage.
function verifyGuestImage {
   scp $WORKSPACE/build_output/guest1.sha512 root@${HOST_IP}:/root/images
   checksum=$(sudo ssh root@${HOST_IP} "cd /root/images/ && sha512sum -c guest1.sha512 | awk '{print \$2}'")
   if [ "$checksum" != "OK" ]; then
      echo "Something wrong with the image, please verify"
      return 1
   fi
}

#Updating the pod.yaml file with HOST_IP,cyclictest-node-context.yaml with loops and interval
function updateYaml {
   cd $WORKSPACE/tests/
   sed -ri "s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/${HOST_IP}/" pod.yaml
   sed -ri "s/loops: [0-9]*/loops: ${testTime}/"  cyclictest-node-context.yaml
   sed -ri "s/interval: [0-9]*/interval: 1000/"  cyclictest-node-context.yaml
}

#cleaning the environment after executing the test through yardstick.
function env_clean {
    container_id=`sudo docker ps -a | grep kvmfornfv_${testType} |awk '{print \$1}'|sed -e 's/\r//g'`
    sudo docker rm ${container_id}
    sudo ssh root@${HOST_IP} "rm -rf /root/workspace/*"
    sudo ssh root@${HOST_IP} "pid=\$(ps aux | grep 'qemu' | awk '{print \$2}' | head -1); echo \$pid |xargs kill"
    sudo rm -rf /tmp/kvmtest-${testType}*
}

#Cleaning the latest kernel changes on host after executing the test.
function host_clean {
    sudo ssh root@${HOST_IP} "rpm=\$(rpm -qa | grep 'kernel-${KERNELRPM_VERSION}' | awk '{print \$1}'); rpm -ev \$rpm"
    sudo ssh root@${HOST_IP} "rm -rf /boot/initramfs-${KERNELRPM_VERSION}*.img"
    sudo ssh root@${HOST_IP} "grub2-mkconfig -o /boot/grub2/grub.cfg"
    sudo ssh root@${HOST_IP} "reboot"
}

function cleanup {
   output=$1
   env_clean
   host_clean
   if [ $output != 0 ];then
      echo "Yardstick Failed.Please check cyclictest.sh"
      return 1
   else
      return 0
   fi
}

#Creating a docker image with yardstick installed and Verify the results of cyclictest
function runCyclicTest {
   docker_image_dir=$WORKSPACE/docker_image_build
   ( cd ${docker_image_dir}; sudo docker build  -t kvmfornfv:latest --no-cache=true . )
   if [ ${?} -ne 0 ] ; then
      echo  "Docker image build failed"
      id=$(sudo docker ps -a  | head  -2 | tail -1 | awk '{print $1}'); sudo docker rm -f $id
      exit 1
   fi
   time_stamp=$(date +%Y%m%d%H%M%S)
   volume=/tmp/kvmtest-${testType}-${time_stamp}
   mkdir -p $volume/{image,rpm,scripts}

   #copying required files to run yardstick cyclic testcase
   mv $WORKSPACE/build_output/kernel-${KERNELRPM_VERSION}*.rpm ${volume}/rpm
   cp -r $WORKSPACE/ci/envs/* ${volume}/scripts
   cp -r $WORKSPACE/tests/cyclictest-node-context.yaml ${volume}
   cp -r $WORKSPACE/tests/pod.yaml ${volume}/scripts

   #Launching ubuntu docker container to run yardstick
   sudo docker run -i -v ${volume}:/opt --net=host --name kvmfornfv_${testType} \
   kvmfornfv:latest  /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh $testType"
   cyclictest_output=$?
   #Verifying the results of cyclictest

   if [ "$testType" == "verify" ];then
      result=`grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`

      if [ -z "${result}" ]; then
         echo "####################################################"
         echo ""
         echo `grep -o '"data":[^}]*' ${volume}/yardstick.out | awk -F '{' '{print $2}'`
         echo ""
         echo "####################################################"
         cleanup $cyclictest_output
      else
         echo "Testcase failed"
         echo `grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`
         env_clean
         host_clean
         return 1
      fi
   else
      cleanup $cyclictest_output
   fi
}

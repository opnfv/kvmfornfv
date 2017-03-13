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
testName=$4

source $WORKSPACE/ci/envs/utils.sh
source $WORKSPACE/ci/envs/host-config
KERNELRPM_VERSION=$( getKernelVersion )
QEMURPM_VERSION=$( getQemuVersion )

if [ -z ${KERNELRPM_VERSION} ];then
   echo "Kernel RPM not found in build_output Directory"
   exit 1
fi
if [ -z ${QEMURPM_VERSION} ];then
   echo "QEMU RPM not found in build_output Directory"
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

#Verifying the availability of the host after reboot
function connect_host {
   n=0
   while [ $n -lt 25 ]; do
      host_ping_test="ping -c 1 ${HOST_IP}"
      eval $host_ping_test &> /dev/null
      if [ ${?} -ne 0 ] ; then
         sleep 10
         echo "host machine is still under reboot..trying to connect...."
         n=$(($n+1))
      else
         echo "resuming the execution of test cases....."
         #Waiting for ssh to be available for the host machine.
         sleep 30
         break
      fi
      if [ $n == 24 ];then
         echo "Host machine unable to boot-up!"
         exit 1
      fi
   done
}

#Updating the pod.yaml file with HOST_IP,kvmfornfv_cyclictest_idle_idle.yaml with loops and interval
function updateYaml {
   cd $WORKSPACE/tests/
   sed -ri "s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/${HOST_IP}/" pod.yaml
   sed -ri "s/loops: [0-9]*/loops: ${testTime}/"  kvmfornfv_cyclictest_hostenv_guestenv.yaml
   sed -ri "0,/interval: [0-9]*/s//interval: 1000/"  kvmfornfv_cyclictest_hostenv_guestenv.yaml
   cp kvmfornfv_cyclictest_hostenv_guestenv.yaml kvmfornfv_cyclictest_${testName}.yaml
   sed -ri "s/tc: \"kvmfornfv_cyclictest-node-context\"/tc: \"kvmfornfv_cyclictest_${testName}\"/" kvmfornfv_cyclictest_${testName}.yaml
   case $testName in

       idle_idle)
                ;;
       cpustress_idle)
                      sed -i '/host-run-qemu.sh/a\    \- \"stress_daily.sh cpu\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
       memorystress_idle)
                      sed -i '/host-run-qemu.sh/a\    \- \"stress_daily.sh memory\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
       iostress_idle)
                      sed -i '/host-run-qemu.sh/a\    \- \"stress_daily.sh io\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
       idle_cpustress)
                      sed -i '/guest-setup1.sh/a\    \- \"stress_daily.sh cpu\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
       idle_memorystress)
                      sed -i '/guest-setup1.sh/a\    \- \"stress_daily.sh memory\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
       idle_iostress)
                      sed -i '/guest-setup1.sh/a\    \- \"stress_daily.sh io\"' kvmfornfv_cyclictest_${testName}.yaml
                      sed -i '/host-setup0.sh/,/host-setup1.sh/ d' kvmfornfv_cyclictest_${testName}.yaml
                      ;;
        *)
          echo "Incorrect test environment: $testName"
          exit 1
          ;;
    esac
}

#cleaning the environment after executing the test through yardstick.
function env_clean {
    container_id=`sudo docker ps -a | grep kvmfornfv_${testType} |awk '{print \$1}'|sed -e 's/\r//g'`
    sudo docker stop ${container_id}
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
    sudo ssh root@${HOST_IP} "rpm=\$(rpm -qa | grep 'qemu-${QEMURPM_VERSION}'| awk '{print \$1}'); rpm -ev \$rpm"
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
   container_id=`sudo docker ps -a | grep kvmfornfv_${testType} |awk '{print \$1}'|sed -e 's/\r//g'`
   echo "$container_id"
   if [ -z "$container_id" ]; then
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
      cp $WORKSPACE/build_output/kernel-${KERNELRPM_VERSION}*.rpm ${volume}/rpm
      cp $WORKSPACE/build_output/qemu-${QEMURPM_VERSION}*.rpm ${volume}/rpm
      cp -r $WORKSPACE/ci/envs/* ${volume}/scripts
      cp -r $WORKSPACE/tests/kvmfornfv_cyclictest_${testName}.yaml ${volume}
      cp -r $WORKSPACE/tests/pod.yaml ${volume}/scripts
      #Launching ubuntu docker container to run yardstick
      container_id=`sudo docker run -i -d -v ${volume}:/opt --net=host --name kvmfornfv_${testType} \
      kvmfornfv:latest`
      sudo docker exec -i $container_id /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh $testType $testName"
      cyclictest_output=$?
   else
      cp -r $WORKSPACE/tests/kvmfornfv_cyclictest_${testName}.yaml ${volume}
      sudo docker exec -i $container_id /bin/bash -c "cd /opt/scripts && ls; ./cyclictest.sh $testType $testName"
      cyclictest_output=$?
   fi
   
   if [ "$testName" == "iostress_idle" ];then
      copyLogs
   fi

   #Verifying the results of cyclictest
   if [ "$testType" == "verify" ];then
      result=`grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`

      if [ -z "${result}" ] && [ "${cyclictest_output}" == 0 ]; then
         echo "####################################################"
         echo " "
         echo `grep -o '"data":[^}]*' ${volume}/yardstick.out | awk -F '{' '{print $2}'`
         echo ""
         echo "####################################################"
         return 0
      else
         echo "Testcase failed"
         echo `grep -o '"errors":[^,]*' ${volume}/yardstick.out | awk -F '"' '{print $4}'`
         return 1
      fi
   fi
}
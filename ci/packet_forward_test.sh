#!/bin/bash
HOST_IP=$1
echo $HOST_IP
source $WORKSPACE/ci/envs/utils.sh
KERNELRPM_VERSION=$( getKernelVersion )

function connect_host {
   n=0
   while [ $n -lt 25 ]; do
      host_ping_test="ping -c 1 ${HOST_IP}"
      eval $host_ping_test &> /dev/null
      if [ ${?} -ne 0 ] ; then
         sleep 5
         echo "host machine is still under reboot..trying to connect"
         n=$(($n+1))
      else
         echo "resuming execution of the configuration scripts"
         #Waiting for ssh to be available for the host nachine.
         sleep 15
         break
      fi
      if [ $n == 24 ];then
         echo "Host machine unable to boot-up"
         exit 1
      fi
   done
}

function connect_guest {
   n=0
   while [ $n -lt 25 ]; do
      guest_ping_test="ssh -p 5555 root@${HOST_IP} exit"
      eval $guest_ping_test &> /dev/null
      if [ ${?} -ne 0 ] ; then
         sleep 5
         echo "guest vm is still under reboot..trying to connect"
         n=$(($n+1))
      else
         echo "resuming execution of the configuration scripts"
         #Waiting for ssh to be available for the guest nachine.
         sleep 15
         break
      fi
      if [ $n == 24 ];then
         echo "Host machine unable to boot-up"
         exit 1
      fi
   done
}

#Creating workspace for copying scripts and rpms
connect_host
ssh root@$HOST_IP "mkdir -p /root/workspace/image"
ssh root@$HOST_IP "mkdir -p /root/workspace/rpm"
ssh root@$HOST_IP "mkdir -p /root/workspace/scripts"
#Copying the configuration scipts on to host
scp -r $WORKSPACE/ci/envs/* root@$HOST_IP:/root/workspace/scripts
scp -r $WORKSPACE/ci/envs/test_cases.sh jenkins@$HOST_IP:/home/jenkins/
scp -r $WORKSPACE/build_output/kernel-${KERNELRPM_VERSION}*.rpm root@$HOST_IP:/root/workspace/rpm

#executing host configuration scripts
ssh root@$HOST_IP "cd /root/workspace/scripts && ./host-setup0.sh"
if [ ${?} -ne 0 ] ; then
   echo "host configuration failed"
   exit 1
fi
ssh root@$HOST_IP "reboot"
sleep 5
connect_host
ssh root@$HOST_IP "cd /root/workspace/scripts && ./host-setup1.sh"

#executing VSWITCHPERF test cases
ssh jenkins@$HOST_IP "cat vsperf_testcases.sh | scl enable python33 -"
if [ ${?} -ne 0 ] ; then
   echo "Execution of packet forwarding test case failed. Please check the logs"
   exit 1
fi

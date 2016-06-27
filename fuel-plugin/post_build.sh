#!/bin/bash

#cd /home/tcs/kvmfornfv/fuel-plugin/repositories/centos/x86_64 
#recent_centos=$(ls -t | head -n1)

#cd /home/tcs/kvmfornfv/fuel-plugin/repositories/ubuntu
#recent_debian=$(ls -t | head -n1)

#echo "$recent_centos" build
#echo "$recent_debian" build

#these build are over-written, so may be we need to transfer it to 2 testing machines (ubuntu and centos).
# the naming convention for these new builds can be appended with "new_"
# new_kvm_build.sh file to be run to use these new builds
# if successful till cyclictest, then copy these new builds with old build names, else delete it
#sshpass should be installed

srcdir="/home/tcs/kvmfornfv/fuel-plugin/repositories/centos/x86_64"
target_ip="10.138.77.198" # target_ip is the testbed
dstdir="/root/rpmbuild/RPMS/x86_64"

for srcfile in ${srcdir}/*
do
  dstfile="new_$(basename $srcfile)"
  # copying new deb and rpm packages to testbed
  sudo sshpass -p root scp $srcfile root@$target_ip:$dstdir/$dstfile
  # execute all tests for host-setup to guest and cyclictest
  #sshpass -p root ssh -o StrictHostKeyChecking=no -l root 10.138.77.198 "cd /home/tcs/opnfv/kvmfornfv/ci/envs/ && ./execute.sh 2>&1 | tee error.log"
done

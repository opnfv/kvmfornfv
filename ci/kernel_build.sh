#!/bin/bash

source ./ci/kernelConfigValidate.sh

kernel_build_validate $@
kernel_build_prep

echo "job name is: $JOB_NAME"
job_type=`echo $JOB_NAME | cut -d '-' -f 2`
echo "job_type is: $job_type"

kernel_rpm_build() {
   rpmbuild_dir=/tmp/kvmfornfv_rpmbuild.$$
   artifact_dir=${rpmbuild_dir}/RPMS/x86_64
   mkdir -p $artifact_dir
   # Make timestamp part of version string for automated kernel boot verification
   date "+-%y%m%d%H%M" > "${kernel_src_dir}/localversion-zzz"

   (cd ${kernel_src_dir}; make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg)
   if [ ${?} -ne 0 ] ; then
      echo "${0}: Kernel build failed"
      rm -rf ${rpmbuild_dir}
      exit 1
   fi
   if [ $job_type == "verify" ] ; then
      rm -f ${artifact_dir}/kernel-debug*
   fi
   cp -f ${artifact_dir}/* ${output_dir}
   rm -rf ${rpmbuild_dir}
}

quirks(){
   #
   # Apply out of tree patches
   #
   SRC=/root
   for i in $SRC/kvmfornfv/patches/$1/*.patch
   do
      if [ -f "$i" ]
      then
         echo "Applying: $i"
         patch -p1 <$i
      fi
   done
}

kernel_deb_build(){
   VERSION="1.0.OPNFV"
   # Configure the kernel
   cd kernel

# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

# Build the kernel debs
make-kpkg clean
fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers kernel_debug -j$(nproc)
make
if [ $job_type == "verify" ] ; then
   rm -f /root/kvmfornfv/*dbg*
fi   
mv /root/kvmfornfv/linux-* /root/kvmfornfv/build_output
}

if [ $pkg_type == "centos" ];then
   kernel_rpm_build
elif [ $pkg_type == "ubuntu" ];then
   quirks kernel
   kernel_deb_build
fi


#!/bin/bash

output_dir="$1"
installer_type="$2"
function checkout_commit() {
build_dir=/opt/kvmfornfv/
mkdir -p /tmp/kvmfornfv
SRC=/tmp/kvmfornfv
if [[ "$installer_type" == "apex" ]];then
   source ${build_dir}/ci/apex.conf
else
   source ${build_dir}/ci/compass.conf
fi
#Cloning into /tmp/kvmfornfv
cd $SRC
if [[ "$branch" == "master" ]] || [[ "$branch" == *"danube"* ]];then
   echo "Cloning the repository of $branch given"
   git clone -b $branch https://gerrit.opnfv.org/gerrit/kvmfornfv.git /tmp/kvmfornfv
   git branch
   echo "Commit-id is ${commit_id}"
   git checkout -f ${commit_id}
   if [ $? -ne 0 ];then
      echo "Please check the commit-id provided in installer conf file"
      exit 1
   fi
fi
mkdir ${output_dir}
}

checkout_commit

kernel_src_dir=$SRC/kernel
config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"
cp -f ${config_file} "${kernel_src_dir}/.config"

usage () {
    echo "usage: ${0} output_dir"
    exit 1
}

if [[ -z "$@" ]]; then
    usage
fi

if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
    echo "${0}: Output directory '${output_dir}' does not exist or cannot \
          be written"
    exit 1
fi

if [ ! -d ${kernel_src_dir} ] ; then
    echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script \
          from the root of kvmfornfv source tree"
    exit 1
fi

if [ ! -f ${config_file} ] ; then
    echo "${0}: ${config_file} does not exist"
    exit 1
fi

echo
echo "Build"
echo

function apex_rpm_build (){
rpmbuild_dir=$SRC/kvmfornfv_rpmbuild.$$
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

cp -f ${artifact_dir}/* ${output_dir}
mv ${output_dir}/* ${build_dir}/build_output/

rm -rf ${rpmbuild_dir}
#cleaning the /tmp
rm -rf ${SRC}
}

function compass_deb_build(){
cd ${kernel_src_dir}
make oldconfig

quirks(){
   #
   # Apply out of tree patches
   #
   echo "Inside quirks"
   for i in $SRC/kvmfornfv/patches/$1/*.patch
   do
      if [ -f "$i" ]
      then
         echo "Applying: $i"
         patch -p1 <$i
      fi
   done
   echo "end quirks"
}
quirks kernel

echo "SRC is:$SRC"
echo "kernel_src_dir is : $kernel_src_dir"

VERSION="1.0.OPNFV"
# Configure the kernel
cd $kernel_src_dir

# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

# Build the kernel debs
make-kpkg clean
fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers kernel_debug -j$(nproc)
make

echo "list the debians built"
ls -lrth $SRC
mv $SRC/linux-* $build_dir/build_output
}

if [[ "$installer_type" == "apex" ]];then
   apex_rpm_build
else
   compass_deb_build
fi


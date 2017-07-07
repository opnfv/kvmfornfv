#!/bin/bash

function checkout_commit() {
build_dir=/opt/kvmfornfv
mkdir -p /tmp/kvmfornfv
SRC=/tmp/kvmfornfv
source ${build_dir}/ci/compass.conf
#Cloning into /tmp/kvmfornfv
cd $SRC
if [[ "$branch" == "master" ]] || [[ "$branch" == *"danube"* ]];then
   echo "Cloning the repository of $branch given"
   git clone $build_dir $SRC
   git branch
   echo "Commit-id is ${commit_id}"
   git checkout -f ${commit_id}
   if [ $? -ne 0 ];then
      echo "Please check the commit-id provided in compass.conf"
      exit 1
   fi
   mkdir $output_dir
fi
}

output_dir="$1"
echo $output_dir
checkout_commit

kernel_src_dir=$SRC/kernel
config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"

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

cp -f ${config_file} "${kernel_src_dir}/.config"
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

echo "Check debians"
ls -lrth $SRC
mv $SRC/linux-* $build_dir/build_output

#!/bin/bash

function checkout_commit() {
build_dir=/opt/kvmfornfv/
mkdir -p /tmp/kvmfornfv
SRC=/tmp/kvmfornfv
source ${build_dir}/ci/compass.conf
cd $SRC
#Cloning into /tmp/kvmfornfv from local repository
git clone $build_dir $SRC
if [ "$branch" == "master" ] || [ "$branch" == "danube" ];then
   echo "Checking out on $branch branch"
   echo "Commit-id is ${commit_id}"
   git checkout -f ${commit_id}
fi
mkdir ${output_dir}
}

output_dir="$1"
checkout_commit

kernel_src_dir=$SRC/kernel

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

echo
echo "Build"
echo

cd $kernel_src_dir
# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

make-kpkg clean
fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers kernel_debug -j$(nproc)
make 
if [ ${?} -ne 0 ] ; then
    echo "Kernel build failed"
    exit 1
fi

mv /root/kvmfornfv/linux-* /root/kvmfornfv/build_output
#cleaning the /tmp
rm -rf ${SRC}

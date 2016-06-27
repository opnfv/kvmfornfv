#!/bin/bash

SRC=/root
kernel_src_dir=kernel
config_file="arch/x86/configs/opnfv.config"
VERSION="1.0.OPNFV"
output_dir="$1"

usage () {
    echo "usage: ${0} output_dir"
    exit 1
}

if [[ -z "$@" ]]; then
    usage
fi

if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
    echo "${0}: Output directory '${output_dir}' does not exist or cannot be written"
    exit 1
fi

if [ ! -d ${kernel_src_dir} ] ; then
    echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
    exit 1
fi

quirks() {
#
# Apply out of tree patches
#
for i in $SRC/kvmfornfv/patches/$1/*.patch
do
    if [ -f "$i" ]
    then
        echo "Applying: $i"
        patch -p1 <$i
    fi
done
}

quirks kernel

cd kernel

if [ ! -f ${config_file} ] ; then
    echo "${0}: ${config_file} does not exist"
    exit 1
fi

# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

# Configure the kernel
cp $config_file .config

make oldconfig </dev/null

# Build the kernel debs
make-kpkg clean

fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers

make

mv /root/kvmfornfv/linux-* /root/kvmfornfv/build_output

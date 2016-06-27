#!/bin/bash

SRC=/root
CONFIG="arch/x86/configs/opnfv.config"
VERSION="1.0.OPNFV"
#OVS_COMMIT="4ff6642f3c1dd8949c2f42b3310ee2523ee970a6"

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

apt-get update
apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc autoconf automake libtool python python-pip

cd $SRC/kvmfornfv/
quirks kernel

cd kernel

# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

# Configure the kernel
cp $CONFIG .config

make oldconfig </dev/null

# Build the kernel debs
make-kpkg clean

fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers

make

mkdir -p /root/debbuild/DEBS
mv /root/kvmfornfv/linux-* /root/debbuild/DEBS/

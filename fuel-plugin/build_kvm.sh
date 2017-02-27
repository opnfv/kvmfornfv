#!/bin/bash

SRC=/root
CONFIG="arch/x86/configs/opnfv.config"
VERSION="1.0.OPNFV"
OVS_COMMIT="4ff6642f3c1dd8949c2f42b3310ee2523ee970a6"

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
apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc autoconf automake libtool python python-pip libssl-dev

#
# Build kernel in another directory, so some files (which are root writeable only) generated during kernel
#   building wouldn't remain in the source directory mapped into Docker container
#
cp -r /kvmfornfv $SRC/.
cd $SRC

# Get the Open VSwitch sources
rm -rf ovs
git clone https://github.com/openvswitch/ovs.git
cd ovs; git checkout $OVS_COMMIT

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

# Build OVS kernel modules
cd ../../ovs

quirks ovs
pip install six

./boot.sh
./configure --with-linux=$SRC/kvmfornfv/kernel
make

# Add OVS kernel modules to kernel deb
dpkg-deb -x $SRC/kvmfornfv/linux-image*.deb ovs.$$
dpkg-deb --control $SRC/kvmfornfv/linux-image*.deb ovs.$$/DEBIAN
cp datapath/linux/*.ko ovs.$$/lib/modules/*/kernel/net/openvswitch
depmod -b ovs.$$ -a `ls ovs.$$/lib/modules`
dpkg-deb -b ovs.$$ $SRC/kvmfornfv/linux-image*.deb
rm -rf ovs.$$

cp $SRC/kvmfornfv/linux-headers*.deb /kvmfornfv/.
cp $SRC/kvmfornfv/linux-image*.deb /kvmfornfv/.


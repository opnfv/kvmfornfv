#!/bin/bash

SRC=/root
CONFIG="arch/x86/configs/opnfv.config"
VERSION="1.0.OPNFV"

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

cp $SRC/kvmfornfv/linux-headers*.deb /kvmfornfv/.
cp $SRC/kvmfornfv/linux-image*.deb /kvmfornfv/.

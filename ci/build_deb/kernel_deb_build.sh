#!/bin/bash

SRC=/root
VERSION="1.0.OPNFV"

source ./functions

kernel_build_validate $@

# TBD why this patches missed on rpm side.
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

kernel_build_prep

# Configure the kernel
cd kernel

# Workaround build bug on Ubuntu 14.04
cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

# Build the kernel debs
make-kpkg clean

fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers

make

mv /root/kvmfornfv/linux-* /root/kvmfornfv/build_output

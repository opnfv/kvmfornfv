#!/bin/bash

# for deb package builds

KVM_COMMIT="0e68cb048bb8aadb14675f5d4286d8ab2fc35449"
OVS_COMMIT="4ff6642f3c1dd8949c2f42b3310ee2523ee970a6"
KEEP=no

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

for i
do
	case $i in

	-k)	KEEP=yes
		shift
		;;

	-c)	KVM_COMMIT=$2
		shift;shift
		;;

#	-o)	OVS_COMMIT=$2
#		shift;shift
#		;;

	esac
done

SRC=${1:-/root}
CONFIG=${2:-arch/x86/configs/opnfv.config}
VERSION=${3:-1.0.OPNFV}

# Check for necessary build tools
if ! type git >/dev/null 2>/dev/null
then
	echo "Build tools missing, run the command

apt-get install git fakeroot build-essential ncurses-dev xz-utils kernel-package automake

as root and try again"
	exit 1
fi

# Make sure the source dir exists
if [ ! -d $SRC ]
then
	echo "$SRC: no such directory"
	exit 1
fi

(
	cd $SRC

	# Get the Open VSwitch sources
#	if [ ! -d ovs ]
#	then
#		git clone https://github.com/openvswitch/ovs.git
#	fi

	# Get the KVM for NFV kernel sources
	if [ ! -d kvmfornfv ]
	then
		#git clone https://gerrit.opnfv.org/gerrit/kvmfornfv
	fi
	cd kvmfornfv
	git pull
	if [ x$KVM_COMMIT != x ]
	then
		git checkout $KVM_COMMIT
	else
		git reset --hard
	fi
	cd kernel

	# Workaround build bug on Ubuntu 14.04
	cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

	quirks kernel

	# Configure the kernel
	cp $CONFIG .config

	make oldconfig </dev/null

	# Build the kernel debs
	if [ $KEEP = no ]
	then
		make-kpkg clean
	fi
	fakeroot make-kpkg --initrd --revision=$VERSION kernel_image kernel_headers
	git checkout arch/x86/boot/install.sh
	git checkout fs/xfs/xfs_super.c

	# Build OVS kernel modules
#	cd ../../ovs
#	if [ x$OVS_COMMIT != x ]
#	then
#		git checkout $OVS_COMMIT
#	else
#		git reset --hard
#	fi

#	quirks ovs

	./boot.sh
	./configure --with-linux=$SRC/kvmfornfv/kernel
	make

	# Add OVS kernel modules to kernel deb
#	dpkg-deb -x $SRC/kvmfornfv/linux-image*.deb ovs.$$
#	dpkg-deb --control $SRC/kvmfornfv/linux-image*.deb ovs.$$/DEBIAN
#	cp datapath/linux/*.ko ovs.$$/lib/modules/*/kernel/net/openvswitch
#	depmod -b ovs.$$ -a `ls ovs.$$/lib/modules`
#	dpkg-deb -b ovs.$$ $SRC/kvmfornfv/linux-image*.deb
#	rm -rf ovs.$$
)

mv $SRC/kvmfornfv/*.deb .

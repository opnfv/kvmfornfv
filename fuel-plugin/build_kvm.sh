#!/bin/bash

KVM_COMMIT="0e68cb048bb8aadb14675f5d4286d8ab2fc35449"
OVS_COMMIT="4ff6642f3c1dd8949c2f42b3310ee2523ee970a6"
KEEP=no

quirks() {
	# Workaround build bug on Ubuntu 14.04
	cat <<EOF > arch/x86/boot/install.sh
#!/bin/sh
cp -a -- "\$2" "\$4/vmlinuz-\$1"
EOF

	# Add deprecated XFS delaylog option back in
	cat <<EOF | patch -p2
diff --git a/kernel/fs/xfs/xfs_super.c b/kernel/fs/xfs/xfs_super.c
index 65a4537..b73ca67 100644
--- a/kernel/fs/xfs/xfs_super.c
+++ b/kernel/fs/xfs/xfs_super.c
@@ -109,6 +109,7 @@ static struct xfs_kobj xfs_dbg_kobj;	/* global debug sysfs attrs */
 #define MNTOPT_GQUOTANOENF "gqnoenforce"/* group quota limit enforcement */
 #define MNTOPT_PQUOTANOENF "pqnoenforce"/* project quota limit enforcement */
 #define MNTOPT_QUOTANOENF  "qnoenforce"	/* same as uqnoenforce */
+#define MNTOPT_DELAYLOG    "delaylog"	/* Delayed logging enabled */
 #define MNTOPT_DISCARD	   "discard"	/* Discard unused blocks */
 #define MNTOPT_NODISCARD   "nodiscard"	/* Do not discard unused blocks */
 
@@ -359,6 +360,9 @@ xfs_parseargs(
 		} else if (!strcmp(this_char, MNTOPT_GQUOTANOENF)) {
 			mp->m_qflags |= (XFS_GQUOTA_ACCT | XFS_GQUOTA_ACTIVE);
 			mp->m_qflags &= ~XFS_GQUOTA_ENFD;
+		} else if (!strcmp(this_char, MNTOPT_DELAYLOG)) {
+			xfs_warn(mp,
+		"delaylog is the default now, option is deprecated.");
 		} else if (!strcmp(this_char, MNTOPT_DISCARD)) {
 			mp->m_flags |= XFS_MOUNT_DISCARD;
 		} else if (!strcmp(this_char, MNTOPT_NODISCARD)) {
-- 
1.9.1

EOF
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

	-o)	OVS_COMMIT=$2
		shift;shift
		;;

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
	if [ ! -d ovs ]
	then
		git clone https://github.com/openvswitch/ovs.git
	fi

	# Get the KVM for NFV kernel sources
	if [ ! -d kvmfornfv ]
	then
		git clone https://gerrit.opnfv.org/gerrit/kvmfornfv
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

	quirks

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
	cd ../../ovs
	if [ x$OVS_COMMIT != x ]
	then
		git checkout $OVS_COMMIT
	else
		git reset --hard
	fi

	#
	# Apply out of tree patches
	#
	for i in $SRC/kvmfornfv/patches/ovs/*.patch
	do
		if [ -f "$i" ]
		then
			echo "Applying: $i"
			patch -p1 <$i
		fi
	done

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
)

mv $SRC/kvmfornfv/*.deb .

#!/bin/bash

##############################################################################
# Copyright (c) 2015 Ericsson AB and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

# This is copy from yardstick-img-modify on yardstick project. Currently 
# yardstick script only ubuntu image, and this one is more for CentOS.
# Example invocation:
# yardstick-img-modify /home/yardstick/tools/ubuntu-server-cloudimg-modify.sh
#
# Warning: the script will create files by default in:
#   /tmp/workspace/yardstick
# the files will be owned by root!
#
# TODO: image resize is needed if the base image is too small
#

set -e
set -x

die() {
    echo "error: $1" >&2
    exit 1
}

usage () {
    echo "$0 cmd workspace"
    exit 1
}

test $# -eq 2 || usage
test $(id -u) -eq 0 || die "should invoke using sudo"

ROOTDIR=$(cd $(dirname "$0")/../.. && pwd)
cmd=$1
test -x $cmd
workspace=$2
mountdir=`mktemp -d`

image_url=${IMAGE_URL:-"http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1510.qcow2"}
md5sums_url=${MD5SUMS_URL:-"http://cloud.centos.org/centos/7/images/sha256sum.txt"}

imgfile="${workspace}/guest.img"
raw_imgfile="${workspace}/guest.raw"
filename=$(basename $image_url)
md5filename=$(basename $md5sums_url)

# download and checksum base image, conditionally if local copy is outdated
download() {
    test -d $workspace || mkdir -p $workspace
    cd $workspace
    rm -f $md5filename # always download the checksum file to a detect stale image
    wget $md5sums_url
    test -e $filename || wget -nc $image_url
    grep "$filename\$" $md5filename |sha256sum -c
    if [ $? -ne 0 ]; then
        rm $filename
        wget -nc $image_url
        grep $filename $md5filename | md5sum -c
    fi
    rm -rf $raw_imgfile
    qemu-img convert $filename $raw_imgfile
    cd -
}

# mount image
setup() {
    mkdir -p $mountdir

    loopdevice=$(kpartx -l $raw_imgfile | head -1 | cut -f1 -d ' ')

    kpartx -a $raw_imgfile
    # No idea why need this sleep
    sleep 3
    mount /dev/mapper/$loopdevice $mountdir

    cmdname=`basename $cmd`
    cp $cmd $mountdir/$cmdname
}

# modify image running a script using in a chrooted environment
modify() {
    # Add the ssh key to the image
    mkdir -p ${mountdir}/root/.ssh
    cp ${ROOTDIR}/ci/envs/kvm4nfv_key.pub ${mountdir}/root/.ssh/authorized_keys
    chmod 700 ${mountdir}/root/.ssh
    chmod 600 ${mountdir}/root/.ssh/authorized_keys
    

    umount $mountdir

    qemu-img convert -O qcow2 $raw_imgfile $imgfile
}

# cleanup (umount) the image
cleanup() {
    # designed to be idempotent
    mount | grep $mountdir && umount $mountdir
    kpartx -d $raw_imgfile || true
    rm -f $raw_imgfile
    rm -rf $mountdir
}

exitcode=""
error_trap()
{
    local rc=$?

    set +e

    if [ -z "$exitcode" ]; then
        exitcode=$rc
    fi

    cleanup

    echo "Image build failed with $exitcode"

    exit $exitcode
}

main() {
    cleanup

    trap "error_trap" EXIT SIGTERM

    download
    setup
    modify

    trap - EXIT SIGTERM
    cleanup

    echo "the modified image is found here: $imgfile"
}

main

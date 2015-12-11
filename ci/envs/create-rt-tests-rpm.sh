#!/bin/bash
##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

usage ()
{
	echo "$0 rpmdir"
	exit 1
}

rpmdir=$1
rm -rf ${rpmdir}/rt-tests-0.96-1.el7.centos.x86_64.rpm
gitdir=`mktemp -d`
ROOTDIR=$(cd $(dirname "$0")/../.. && pwd)
VERSION=v0.96
cd $gitdir
git clone https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
cd rt-tests
git checkout -b ${VERSION} ${VERSION}
patch -p1  -i ${ROOTDIR}/ci/envs/rt-tests.patch
make HAVE_PARSE_CPUSTRING_ALL=1 rpm
cp ./RPMS/x86_64/rt-tests-0.96-1.el7.centos.x86_64.rpm $rpmdir
rm -rf $gitdir


#!/bin/bash
##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

# Entry script for kvm4nfv verification. Currently we have only cyclictest to 
# invoke. More will be added in future.

ROOT_DIR=$(cd $(dirname "$0")/.. && pwd)
ENVDIR=${ROOT_DIR}/ci/envs/

rpmdir=`mktemp -d`
imgdir=`mktemp -d`

# Prepare the rpms for testing
${ROOT_DIR}/ci/build.sh ${rpmdir}

# Didn't find rt-test rpm for CentOS, build it ourselves.
${ROOT_DIR}/ci/envs/create-rt-tests-rpm.sh ${rpmdir}

# Create the guet image file for testing
${ROOT_DIR}/ci/envs/guest-modify.sh  ${imgdir}

# Trigger the cyclictest testing
${ROOT_DIR}/tests/cyclictest.sh ${rpmdir} ${imgdir}

# Clearn the environment
rm -rf ${rpmdir}
rm -rf ${imgdir}

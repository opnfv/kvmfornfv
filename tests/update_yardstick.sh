#!/bin/bash
##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

usage () {
	echo "update_yardstick.sh container_id rpmdir imagedir"
	exit 1
}

if [ $# -ne 3 ] || [ ! -d $2 ] || [ ! -d $3 ]
then
    usage
fi

DBASE_DIR=/opt

ROOTDIR=$(cd $(dirname "$0")/.. && pwd)
ENVDIR=${ROOTDIR}/ci/envs/

CID=$1
RPMDIR=$2
IMGDIR=$3

docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/scripts/"
docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/rpm/"
docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/image/"

copyfile () {
    docker cp $1 "${CID}:${DBASE_DIR}/$2"
    if [[ -z $? ]]
    then
        echo "Failed to copy $2"
        exit 1
    fi
}

# Copy the environment setup scripts to the docker image
copyfile ${ENVDIR}/host-setup0.sh 'scripts/'
copyfile ${ENVDIR}/host-setup1.sh 'scripts/'
copyfile ${ENVDIR}/host-config 'scripts/'
copyfile ${ENVDIR}/guest-setup0.sh 'scripts/'
copyfile ${ENVDIR}/guest-setup1.sh 'scripts/'
copyfile ${ENVDIR}/host-run-qemu.sh 'scripts/'
copyfile ${ENVDIR}/kvm4nfv_key 'yardstick_key'

copyfile "${ROOTDIR}/tests/testexec.sh" 'testexec.sh'

# Copy the test yaml definition to the docker image
copyfile "${ROOTDIR}/tests/pod.yaml" 'pod.yaml'
copyfile "${IMGDIR}/guest.img" 'image/'

docker cp "${ROOTDIR}/tests/cyclictest-node-context.yaml" 	${CID}:${DBASE_DIR}

# Copy the rpms
for f in ${RPMDIR}/*.rpm
do
	docker cp $f  ${CID}:${DBASE_DIR}/rpm/
done

# If we have any yardstick patch for workaround, copy it
if [ -e "${ROOTDIR}/tests/yardstick.patch" ]
then
	docker cp ${ROOTDIR}/tests/yardstick.patch ${CID}:${DBASE_DIR}/
fi

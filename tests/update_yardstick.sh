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

DBASE_DIR=/opt

ROOTDIR=$(cd $(dirname "$0")/.. && pwd)
ENVDIR=${ROOTDIR}/ci/envs/

CID=$1
RPMDIR=$2
IMGDIR=$3

docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/scripts/"
docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/rpm/"
docker exec ${CID} sh -c "mkdir -p ${DBASE_DIR}/image/"

# Copy the environment setup scripts to the docker image
docker cp ${ENVDIR}/host-setup0.sh 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/host-setup1.sh 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/host-config 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/guest-setup0.sh 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/guest-setup1.sh 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/host-run-qemu.sh 	${CID}:${DBASE_DIR}/scripts/
docker cp ${ENVDIR}/kvm4nfv_key ${CID}:${DBASE_DIR}/yardstick_key

docker cp ${ROOTDIR}/tests/testexec.sh ${CID}:${DBASE_DIR}

# Copy the test yaml definition to the docker image
docker cp ${ROOTDIR}/tests/pod.yaml 	${CID}:${DBASE_DIR}
docker cp ${ROOTDIR}/tests/cyclictest-node-context.yaml 	${CID}:${DBASE_DIR}

# Copy the rpms
for f in ${RPMDIR}/*.rpm
do
	docker cp $f  ${CID}:${DBASE_DIR}/rpm/
done
docker cp ${IMGDIR}/guest.img ${CID}:${DBASE_DIR}/image/

# If we have any yardstick patch for workaround, copy it
if [ -e "${ROOTDIR}/tests/yardstick.patch" ]
then
	docker cp ${ROOTDIR}/tests/yardstick.patch ${CID}:${DBASE_DIR}/
fi

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
	echo "Usage: ${0} rpmdir image_dir"
	exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

rpmdir=$1
imagedir=$2

ROOT_DIR=$(cd $(dirname "$0")/.. && pwd)
ENVDIR=${ROOT_DIR}/ci/envs/

cleanup () {
    docker  stop  $1
    docker  rm -v $1
    # We should have already remove running containers when pull the image
    docker rmi opnfv/yardstick
}

# Make sure we have latest image
docker ps | grep opnfv/yardstick-ci |\
	awk '{print $1}' | xargs -r docker stop &>/dev/null
	docker ps -a | grep opnfv/yardstick |\
		awk '{print $1}' | xargs -r  docker rm &>/dev/null
docker pull opnfv/yardstick

id=$(docker run \
--privileged=true \
-d \
-t \
-e "INSTALLER_TYPE=${INSTALLER_TYPE}" \
-e "INSTALLER_IP=${INSTALLER_IP}" \
opnfv/yardstick )

trap 'cleanup $id' SIGHUP SIGINT SIGTERM

${ROOT_DIR}/tests/update_yardstick.sh $id ${rpmdir} ${imagedir}

if [[ -z $? ]]
then
    echo "Failed to update the yardstick environment"
    exit 1
fi

docker exec $id sh -c "/opt/testexec.sh"

cleanup $id

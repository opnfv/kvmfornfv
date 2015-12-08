#!/bin/bash
##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

set -e
set -o errexit
set -o pipefail

: ${YARDSTICK_REPO:='https://gerrit.opnfv.org/gerrit/yardstick'}
: ${YARDSTICK_REPO_DIR:='/home/opnfv/repos/yardstick'}
: ${YARDSTICK_BRANCH:='master'} # branch, tag, sha1 or refspec

: ${INSTALLER_TYPE:='fuel'}
: ${INSTALLER_IP:='10.20.0.2'}

: ${POD_NAME:='opnfv-jump-2'}
: ${EXTERNAL_NET:='net04_ext'}

export https_proxy=https://proxy.sc.intel.com:911/
export http_proxy=http://proxy.sc.intel.com:911/

git_checkout()
{
    if git cat-file -e $1^{commit} 2>/dev/null; then
        # branch, tag or sha1 object
        git checkout $1
    else
        # refspec / changeset
        git fetch --tags --progress $2 $1
        git checkout FETCH_HEAD
    fi
}

echo
echo "INFO: Updating yardstick -> $YARDSTICK_BRANCH"
if [ ! -d $YARDSTICK_REPO_DIR ]; then
    git clone YARDSTICK_REPO $YARDSTICK_REPO_DIR
fi
cd $YARDSTICK_REPO_DIR


git checkout master && git pull
git_checkout $YARDSTICK_BRANCH $YARDSTICK_REPO

export EXTERNAL_NET INSTALLER_TYPE POD_NAME

# Verifiy

DISPATCHER_TYPE=file
DISPATCHER_FILE_NAME="/tmp/yardstick.out"

exitcode=""

error_exit()
{
    local rc=$?

    if [ -z "$exitcode" ]; then
        # In case of recursive traps (!?)
        exitcode=$rc
    fi

    echo "Exiting with RC=$exitcode"

    exit $exitcode
}


install_yardstick()
{
    echo
    echo "========== Installing yardstick =========="

    if ! sudo -E python setup.py install; then
        echo 'Yardstick installation failed!'
        exit 1
    fi
}


run_test()
{
    echo
    echo "========== Running yardstick test suites =========="

    mkdir -p /etc/yardstick

    cat << EOF >> /etc/yardstick/yardstick.conf
[DEFAULT]
debug = True
dispatcher = ${DISPATCHER_TYPE}

[dispatcher_file]
file_name = ${DISPATCHER_FILE_NAME}

[dispatcher_http]
timeout = 5
target = ${DISPATCHER_HTTP_TARGET}
EOF

    local failed=0

    echo "----------------------------------------------"
    echo "Running samples/cyclictest-node-context.yaml  "
    echo "----------------------------------------------"

    if ! yardstick task start /opt/cyclictest-node-context.yaml; then
        echo "Yardstick test FAILED"
        exit 1
    fi
    echo "----------------------------------------------"
    echo "Dump test result:                             "
    cat /tmp/yardstick.out
    echo "----------------------------------------------"
}


verifiy()
{
    GITROOT=$YARDSTICK_REPO_DIR

    cd $GITROOT

    export YARDSTICK_VERSION=$(git rev-parse HEAD)

    # fetch patch
    git fetch https://QiLiang@gerrit.opnfv.org/gerrit/yardstick refs/changes/33/3633/1 && git checkout FETCH_HEAD

    # If any change needed for yardstick, applied here.
    if [ -e /opt/yardstick.patch ]
    then
        patch -p1 -i /opt/yardstick.patch
    fi
    # install yardstick
    install_yardstick

    trap "error_exit" EXIT SIGTERM

    run_test
}


verifiy


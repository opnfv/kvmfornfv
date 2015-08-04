#!/bin/bash

XTRACE=$(set +o | grep xtrace)
set +o xtrace

TOP_DIR=$(cd $(dirname "$0")/.. && pwd)

cp $TOP_DIR/tools/opnfv.config $TOP_DIR/kernel/.config
pushd $TOP_DIR/kernel

JN=`lscpu |grep "^CPU(s)" |cut -d ':' -f 2`
make -j $JN $@

popd

$XTRACE

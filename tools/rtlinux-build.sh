#!/bin/bash

XTRACE=$(set +o | grep xtrace)
set +o xtrace

TOP_DIR=$(cd $(dirname "$0")/.. && pwd)

if [ ! -f $TOP_DIR/kernel/.config ]; then
	cp $TOP_DIR/tools/opnfv.config $TOP_DIR/kernel/.config
fi
pushd $TOP_DIR/kernel &>/dev/null

JN=`lscpu |grep "^CPU(s)" |cut -d ':' -f 2`
make -j $JN $@

popd &> /dev/null

$XTRACE

#!/bin/bash

###########################################################
## Invoking this script from ubuntu docker container runs
## cyclictest through yardstick
###########################################################

pod_config='/opt/pod.yaml'
cyclictest_context_file='/opt/cyclictest-node-context.yaml'

if [ ! -f ${pod_config} ] ; then
    echo "file ${pod_config} not found"
    exit 1
fi

if [ ! -f ${cyclictest_context_file} ] ; then
    echo "file ${cyclictest_context_file} not found"
    exit 1
fi

#Running cyclictest through yardstick
yardstick -d task start ${cyclictest_context_file}
cat /tmp/yardstick.out  > /opt/yardstick.out

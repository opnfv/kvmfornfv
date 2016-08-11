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

#Verifying the results of cyclictest
result=`grep -o '"errors":[^,]*' /opt/yardstick.out | awk -F '"' \
'{print $4}'| awk '{if (NF=0) print "SUCCESS" }'`
if [ "$result" = "SUCCESS" ]; then
    echo "####################################################"
    echo ""
    echo `grep -o '"data":[^}]*' /opt/yardstick.out | awk -F '{' '{print $2}'`
    echo ""
    echo "####################################################"
    exit 0
else
    echo "Testcase failed"
    echo `grep -o '"errors":[^,]*' /opt/yardstick.out | awk -F '"' '{print $4}'`
    exit 1
fi


#!/bin/bash

source guest-config

PATH=/root/tests:${PATH}

result=`mktemp`
failed=0

# Warm up
cyclictest -a ${guest_isolcpus} -t1 -p 99 -n -m -i 1000 -l 1000 -h 90 -q > /dev/null

#taskset -c ${guest_isolcpus} stress --cpu 1 &

cyclictest -a ${guest_isolcpus} -t1 -p 99 -n -m -i ${cyclictest_interval} -l ${cyclictest_loop} -h 90 -q | tee ${result}

#pkill stress

latency=`grep "Avg Latencies" ${result} | cut -d : -f 2`
if [ ${latency} -gt 10 ] ; then
    echo "cyclictest failed, average latency is ${latency}"
    failed=1
fi

latency=`grep "Max Latencies" ${result} | cut -d : -f 2`
if [ ${latency} -gt 20 ] ; then
    echo "cyclictest failed, maximum latency is ${latency}"
    failed=1
fi

rm -f ${result}

shutdown +1

exit ${failed}

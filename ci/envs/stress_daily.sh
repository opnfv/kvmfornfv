#!/bin/bash
source host-config

timeout=10m
ARGS="--cpu=100"
#stress_isolcpus will hold range as a value i.e, eg :24-43
sh stress_scripts.sh -c ${stress_isolcpus} -t $timeout -a $ARGS

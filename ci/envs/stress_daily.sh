#!/bin/bash
source host-config

stress_type=$1
timeout=10m

case $stress_type in
   cpu) # processor
      ARGS="--cpu=100"
      ;;
   memory)
      ARGS="--vm=100"
      ;;
   io)
      ARGS="--io 10,--hdd 100"
      ;;
   *)
      echo $"Usage: $0 {cpu|memory|io}"
      exit 1
esac

#stress_isolcpus will hold range as a value i.e, eg :24-43
sh stress_scripts.sh -c ${stress_isolcpus} -t $timeout -a $ARGS

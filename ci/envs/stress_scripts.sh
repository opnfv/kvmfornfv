################################################################
#This script will impose stress on specified processors with the
#arguments passed based on stress type.
################################################################
#!/bin/bash
function usage() {
    echo ""
    echo "Usage --> $0 [-c CPU] [-t timeout] [-a stress-args][-h]"
    echo "  CPU : 1/0-2 ;  default is 22-43"
    echo "  timeout : N(number)"
    echo "  stress-args : "--cpu=100 --vm=100 --io=10 --hdd=100""
    echo "  -h : Help section"
    echo ""
}

##  --- Parse command line arguments / parameters ---
while getopts ":c:t:a:h" option; do
    case $option in
        c) # processor
          processors=$OPTARG
          ;;
        t) # output_dir
          timeout=$OPTARG
          ;;
        a)#istress args
          args=$OPTARG
          ;;
        :)
          echo "Option -$OPTARG requires an argument."
          usage
          exit 1
          ;;
        h)
          usage
          exit 0
          ;;
        *)
          echo "Unknown option: $OPTARG."
          usage
          exit 1
          ;;
        ?)
          echo "[WARNING] Unknown parameters!!!"
          echo "Using default values for CPU,timeout and stress parameters"
    esac
done


if [[ -z "$processors" ]]
then
    processors='22-43'
fi

if [[ -z "$timeout" ]]
then
   timeout='10m'
fi

if [[ -z "$args" ]]
then
   args="--cpu=100"
fi

stress_params=$(echo $args | sed 's/[,=]/ /g'|sed -e 's/\r//g')

cmd="taskset -c $processors stress --timeout ${timeout} ${stress_params}"

echo $cmd

eval "${cmd}" &>/dev/null &disown

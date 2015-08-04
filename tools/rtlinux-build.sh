#!/bin/bash

XTRACE=$(set +o | grep xtrace)
set +o xtrace

TOP_DIR=$(cd $(dirname "$0")/.. && pwd)

help()
{
	echo "usage: ./rtlinux-build.sh -h -f -n kernel_build_parameter"
	echo "Available options"
	echo "-f: overwrite kernel config if changed"
	echo "-n: not overwrite kernel config even if changed"
	echo "-h: help"
	echo "kernel_build_parameter: to be passed to kernel make command"
}

overwrite=na
for i in "$@"; do
case $i in
	-f)
	if [ "$overwrite" = "no" ]; then
		echo "Conflict parameter!"
		exit
	fi
	overwrite=yes
	shift
	;;
	-n)
	if [ "$overwrite" = yes ]; then
		echo "Conflict parameter!"
		exit
	fi
	overwrite=no
	shift
	;;
	-h)
		help
		exit
	;;
	*)
	;;
esac
done

# Will copy the configs/opnfv.config to kernel .config if
# a) kernel .config file does not exist or,
# b) Kernel .config file is different with opnfv.config
#    and '-f' parameter provided, or
# c) kernel .config file is different with opnfv.config, no '-n'
#    parameter provided, and user input 'yes/y' on interactive

CHANGED=0
if [ -f $TOP_DIR/kernel/.config ]; then
	diff $TOP_DIR/tools/configs/opnfv.config $TOP_DIR/kernel/.config > /dev/null
	CHANGED=$?
else
	overwrite=yes
fi

if [ $CHANGED -eq 1 -a "$overwrite" == "na" ]; then
	read -p "The kernel config file is changed, do you want to overwrite (y/n)?" answer
	case "$answer" in
	y|Y)
			overwrite=yes
	;;
	n|N)
			overwrite=no
	;;
	*)
		echo "Please input y/n"
		exit
	;;
	esac
fi

if [ "$overwrite" == "yes" ]; then
	echo "Overwrite kernel .config file"
	cp $TOP_DIR/tools/configs/opnfv.config $TOP_DIR/kernel/.config
fi


(cd $TOP_DIR/kernel; make $@)

$XTRACE

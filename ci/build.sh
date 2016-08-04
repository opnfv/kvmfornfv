#!/bin/bash
kernel_src_dir=kernel
rpmbuild_dir=/tmp/kvmfornfv_rpmbuild.$$
artifact_dir=${rpmbuild_dir}/RPMS/x86_64
config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"

usage () {
    echo "usage: ${0} [-d] output_dir "
    echo " -d: include debug information. Currently it's vmlinux and unstripped module file"
    exit 1
}

while getopts ':d' optchar; do
	case "${optchar}" in
		d) debug_build=true	;;
		*) echo "Non-optoin argument: '-${OPTARG}'" >&2
		    echo "$OPTARG"
		    usage
		    exit 2
		    ;;
	esac
done

shift $((OPTIND-1)) 
if [[ -z "$@" ]]; then
    usage
fi
output_dir="$1"

if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
    echo "${0}: Output directory '${output_dir}' does not exist or cannot be written"
    exit 1
fi

if [ ! -d ${kernel_src_dir} ] ; then
    echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
    exit 1
fi

if [ ! -f ${config_file} ] ; then
    echo "${0}: ${config_file} does not exist"
    exit 1
fi

echo
echo "Build"
echo

cp -f ${config_file} "${kernel_src_dir}/.config"

# Make timestamp part of version string for automated kernel boot verification
date "+-%y%m%d%H%M" > "${kernel_src_dir}/localversion-zzz"

if [ "$debug_build" == true ]; then
	BUILD_ARGS="INSTALL_MOD_STRIP=1"
fi

( cd ${kernel_src_dir}; make V=1 $BUILD_ARGS RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg )
if [ ${?} -ne 0 ] ; then
    echo "${0}: Kernel build failed"
    rm -rf ${rpmbuild_dir}
    exit 1
fi

	
cp -f ${artifact_dir}/* ${output_dir}
if [ "$debug_build" == true ]; then
	cp ${kernel_src_dir}/vmlinux ${output_dir}
fi

rm -rf ${rpmbuild_dir}

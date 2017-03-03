#!/bin/bash

#source /root/kvmfornfv/ci/build_interface.sh 
new_flag=$3

if [ $new_flag -eq 1 ];then
   kernel_src_dir=apex/kvmfornfv/kernel
   kernel_config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"
else
   kernel_src_dir=kernel
   kernel_config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"
fi

function show_stage {
    echo
    echo $1
    echo
}

function kernel_build_validate {
    show_stage "validate"
    if [[ -z "$@" ]]; then
        echo "usage: ${0} output_dir"
        echo "usage: ${1} pkg_type"
        echo "usage: ${2} new_flag"
        usage
    fi
    echo $output_dir
    output_dir="$1"
    pkg_type="$2"
    new_flag="$3"
    echo "$output_dir"
    echo "$new_flag"
    echo "$pkg_type"
    if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
        echo "${0}: Output directory '${output_dir}' does not exist or cannot be written"
        exit 1
    fi
    if [ ! -d ${kernel_src_dir} ] ; then
        echo "${0}: Directory '${kernel_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
        exit 1
    fi

    if [ ! -f ${kernel_config_file} ] ; then
        echo "${0}: ${kernel_config_file} does not exist"
        exit 1
    fi
    echo
    echo "Build"
    echo
}

function kernel_build_prep {
    echo "In Kernel build prep"
    show_stage "kernel tree prep"
    cp -f ${kernel_config_file} "${kernel_src_dir}/.config"
    make oldconfig
}

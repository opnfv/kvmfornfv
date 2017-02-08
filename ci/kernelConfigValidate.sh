#!/bin/bash

kernel_src_dir=kernel
kernel_config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"

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
        usage
    fi
    output_dir="$1"
    pkg_type="$2"
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
    show_stage "kernel tree prep"
    cp -f ${kernel_config_file} "${kernel_src_dir}/.config"
    make oldconfig
}

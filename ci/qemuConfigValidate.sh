#!/bin/bash

qemu_src_dir=qemu
workspace=/root
scripts_dir=ci/build_deb
VERSION=`grep -m 1 "VERSION"  ${qemu_src_dir}/config-host.mak | cut -d= -f2-`

function show_stage {
    echo
    echo $1
    echo
}

function qemu_build_validate {
    show_stage "validate"
    if [[ -z "$@" ]]; then
        echo "usage: ${0} output_dir"
        echo "usage: ${1} pkgtype"
        usage
    fi
    output_dir="$1"
    pkg_type="$2"
    if [ ! -d ${output_dir} -o ! -w ${output_dir} ] ; then
        echo "${0}: Output directory '${output_dir}' does not exist or cannot be written"
        exit 1
    fi
    if [ ! -d ${qemu_src_dir} ] ; then
        echo "${0}: Directory '${qemu_src_dir}' does not exist, run this script from the root of kvmfornfv source tree"
        exit 1
    fi
    
    echo
    echo "Build"
    echo
}


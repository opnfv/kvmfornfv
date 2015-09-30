#!/bin/bash

kernel_src_dir=kernel
ci_dir=ci
rpm_dir="$1"
test_host="$2"

usage () {
    echo "usage: ${0} kernel_rpm_dir test_host"
    exit 1
}

# Force ssh to fail if password is required, and to trust remote host
ssh_opts="-o BatchMode=yes -o StrictHostKeyChecking=no"

ssh_host () {
    ssh ${ssh_opts} root@${test_host} ${*}
    # somehow reboot returns a non-0 return code even it worked fine
    if [[ ${?} -ne 0 && ! "${*}" =~ "reboot" ]] ; then
        echo "${0}: Host remote command '${*}' failed"
        exit 1
    fi
}

ssh_guest () {
    ssh_host ssh ${ssh_opts} -p 5555 localhost ${*}
    if [ ${?} -ne 0 ] ; then
        echo "${0}: Guest remote command '${*}' failed"
        exit 1
    fi
}

scp_host () {
    scp ${ssh_opts} ${*} root@${test_host}:
    if [ ${?} -ne 0 ] ; then
        echo "${0}: Copying '${*}' to host failed"
        exit 1
    fi
}

scp_guest () {
    ssh_host scp ${ssh_opts} -P 5555 ${*} localhost:
    if [ ${?} -ne 0 ] ; then
        echo "${0}: Copying '${*}' to guest failed"
        exit 1
    fi
}

test_host_connection () {
    retry=0

    while [ ${retry} -lt 5 ] ; do
        msg=`ssh ${ssh_opts} root@${test_host} echo Hello`
        if [ ${?} -eq 0 -a "$msg" = "Hello" ] ; then
            return 0
        fi

        sleep 1m
        retry=`expr ${retry} + 1`
    done

    echo "${0}: Failed to connect to '${test_host}' as root"
    exit 1
}

test_guest_connection () {
    retry=0

    while [ ${retry} -lt 5 ] ; do
        msg=`ssh_host ssh ${ssh_opts} -p 5555 localhost echo Hello`
        if [ ${?} -eq 0 -a "$msg" = "Hello" ] ; then
            return 0
        fi

        sleep 1m
        retry=`expr ${retry} + 1`
    done

    echo "${0}: Failed to connect to guest as root"
    exit 1
}

if [[ $# -ne 2 ]]; then
    usage
fi

if [ ! -d ${rpm_dir} -o ! -r ${rpm_dir} ] ; then
    echo "${0}: Output directory '${rpm_dir}' does not exist or cannot be read"
    exit 1
fi

if [ ! -d ${kernel_src_dir} -o ! -d ${ci_dir} ] ; then
    echo "${0}: Run this script from the root of kvmfornfv source tree"
    exit 1
fi

test_host_connection

echo
echo "Verify"
echo

kernel_ver=`cat ${kernel_src_dir}/include/config/kernel.release`

# Copy kernel RPMs and host/guest scripts to host
scp_host ${rpm_dir}/*
scp_host ${ci_dir}/host-*
scp_host ${ci_dir}/guest-*

# Install new kernel on host and reboot
ssh_host rpm -U "kernel-*.rpm"
ssh_host ./host-setup0.sh
ssh_host reboot
test_host_connection

# Verify kernel version on host
rem_kver=`ssh_host uname -r`
if [ "$rem_kver" != "$kernel_ver" ] ; then
    echo "${0}: Test host failed to boot to new kernel"
    exit 1
fi

# After reboot setup on host
ssh_host ./host-setup1.sh

# Start guest
ssh_host ./host-run-qemu.sh
test_guest_connection

# Copy kernel RPMs and guest-only scripts to guest
scp_guest "kernel-*.rpm"
scp_guest "guest-*"
ssh_host rm -f "kernel-*.rpm"

# Install new kernel on guest and reboot
ssh_guest rpm -U "kernel-*.rpm"
ssh_guest rm -f "kernel-*.rpm"
ssh_guest ./guest-setup0.sh
ssh_guest reboot
test_guest_connection

# Verify kernel version on guest
rem_kver=`ssh_guest uname -r`
if [ "$rem_kver" != "$kernel_ver" ] ; then
    echo "${0}: Test guest failed to boot to new kernel"
    exit 1
fi

# After reboot setup on guest
ssh_guest ./guest-setup1.sh

# Run tests and verify results on guest
ssh_guest ./guest-run-tests.sh

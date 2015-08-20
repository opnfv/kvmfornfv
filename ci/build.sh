#!/bin/bash
kernel_src_dir=kernel
rpmbuild_dir=/tmp/kvmfornfv_rpmbuild.$$
artifact_dir=${rpmbuild_dir}/RPMS/x86_64
config_file="${kernel_src_dir}/arch/x86/configs/opnfv.config"
output_dir="$1"

usage () {
    echo "usage: ${0} output_dir"
    exit 1
}

if [[ -z "$@" ]]; then
    usage
fi

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

( cd ${kernel_src_dir}; make RPMOPTS="--define '_topdir ${rpmbuild_dir}'" rpm-pkg )
if [ ${?} -ne 0 ] ; then
    echo "${0}: Kernel build failed"
    rm -rf ${rpmbuild_dir}
    exit 1
fi

cp -f ${artifact_dir}/* ${output_dir}

rm -rf ${rpmbuild_dir}

# Currently we don't have a solution to test the new kernel automatically.
# The kernel should be tested on both host and guest.  Testing will include:

#  Install the kernel RPM packages on host
#  Reboot host to the new kernel
#  Start a guest on host
#  Install the kernel RPM packages on guest
#  Reboot guest to the new kernel
#  Run some test (e.g. cyclictest) on guest
#  Ensure the test results are within predefined limits

# This requires some client/server infrastructure where Jenkins (client)
# can send requests to the test host and guest (servers) through network
# to perform these actions.

# Below is a note from Aric:

#if we have a kvm image we can do something like this to test boot.
#BUILD/kernel-4.1.3_rt3nfv/usr/gen_init_cpio BUILD/kernel-4.1.3_rt3nfv/include/config/initramfs | gzip >initramfs.gz
#qemu-kvm -kernel BUILD/kernel-4.1.3_rt3nfv/arch/x86/boot/bzImage -initrd initramfs.gz -append "console=ttyS0" -nographic

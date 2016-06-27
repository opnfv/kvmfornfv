#!/bin/bash

FROM centos
RUN yum update
RUN yum -y install git gcc gcc-c++ zlib-devel gtk2-devel make gettext bc rpm

# Copy slave kvmfornfv workspace
ADD ./kvmfornfv /root/kvmfornfv

# Copy Kernel and Qemu Rpm build scripts inside docker
RUN mkdir build_qemu
ADD ./mkspec /root/kvmfornfv/ci/build_qemu/
ADD ./mkversion /root/kvmfornfv/ci/build_qemu/
ADD ./qemu_rpm_build.sh /root/kvmfornfv/ci/build_qemu/
RUN mkdir build_kernel
ADD ./kernel_rpm_build.sh /root/kvmfornfv/ci/build_kernel/

# Build qemu rpm packages
WORKDIR /root/kvmfornfv
RUN mkdir build_qemu_rpm
WORKDIR /root/kvmfornfv/qemu
RUN ./configure
RUN make
WORKDIR /root/kvmfornfv
RUN ./ci/build_qemu/qemu_rpm_build.sh build_qemu_rpm

# Build kernel rpm packages
RUN mkdir build_kernel_rpm
RUN ./ci/build_kernel/kernel_rpm_build.sh build_kernel_rpm

# Move Kernel and Qemu Rpm builds into separate directories
RUN mv /root/rpmbuild/RPMS/x86_64/kernel-* build_kernel_rpm/
RUN mv /root/rpmbuild/RPMS/x86_64/qemu-* build_qemu_rpm/

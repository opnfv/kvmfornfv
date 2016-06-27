#!/bin/bash

FROM ubuntu:14.04.3
RUN apt-get update
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc autoconf vim python pkg-config zlibc zlib1g zlib1g-dev libglib2.0-dev libtool
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo

# Copy slave kvmfornfv workspace
ADD ./kvmfornfv /root/kvmfornfv

# Copy Kernel and Qemu Debian build scripts inside docker
RUN mkdir build_qemu
ADD ./mkcontrol.sh /root/kvmfornfv/ci/build_qemu/
ADD ./qemu_deb_build.sh /root/kvmfornfv/ci/build_qemu/
RUN mkdir build_kernel
ADD ./kernel_deb_build.sh /root/kvmfornfv/ci/build_kernel/

# Build qemu debian packages
WORKDIR /root/kvmfornfv
RUN mkdir build_qemu_debian
WORKDIR /root/kvmfornfv/qemu
RUN ./configure
RUN make
WORKDIR /root/kvmfornfv
RUN ./ci/build_qemu/qemu_deb_build.sh build_qemu_debian

# Build kernel debian packages
RUN mkdir build_kernel_debian
RUN ./ci/build_kernel/kernel_deb_build.sh build_kernel_debian

# Move Kernel and Qemu Debian builds into separate directories
RUN mv /root/debbuild/DEBS/linux-* build_kernel_debian/
RUN mv /root/debbuild/qemu-* build_qemu_debian/

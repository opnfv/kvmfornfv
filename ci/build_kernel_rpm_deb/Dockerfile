#!/bin/bash
FROM ubuntu
RUN apt-get update
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc autoconf
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo
#clone new changes on the configured kvmfornfv_slave, inside JJB_KVM workspace
ADD ./kvmfornfv_slave/workspace/JJB_KVM /root/kvmfornfv

#build .deb packages
ADD ./build_deb_kvm.sh /root/kvmfornfv/build_deb_kvm.sh
RUN chmod 755 /root/kvmfornfv/build_deb_kvm.sh
RUN /root/kvmfornfv/build_deb_kvm.sh

#build rpm packages
ADD ./build_rpm_package.sh /root/kvmfornfv/build_rpm_package.sh
ADD ./build_rpm_kvm.sh /root/kvmfornfv/build_rpm_kvm.sh
RUN chmod 755 /root/kvmfornfv/build_rpm_package.sh
RUN /root/kvmfornfv/build_rpm_package.sh

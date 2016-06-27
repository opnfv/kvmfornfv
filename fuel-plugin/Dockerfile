#!/bin/bash
# created a preconfigured docker image "ubuntu", with proxy settings done and net connectivity
FROM ubuntu
RUN apt-get update
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils kernel-package bc autoconf
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo
ADD ./fuel-slave/workspace/kvm-gerrit/test /root/kvmfornfv

#build .deb packages
ADD ./build_kvm.sh /root/build_kvm.sh
RUN chmod +x /root/build_kvm.sh
RUN /root/build_kvm.sh

#build rpm packages
ADD ./test_build.sh /root/test_build.sh
ADD ./rpm_build.sh /root/build.sh
RUN chmod +x /root/test_build.sh
RUN ./root/test_build.sh


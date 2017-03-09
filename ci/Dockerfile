#!/bin/bash

FROM centos
RUN yum -y update && yum -y install \
  git \
  gcc \
  gcc-c++ \
  zlib-devel \
  gtk2-devel \
  glib2-devel \
  make \
  gettext \
  bc \
  bison\
  flex\
  rpm \
  rpm-build
RUN git clone https://gerrit.opnfv.org/gerrit/kvmfornfv.git /tmp/kvm/

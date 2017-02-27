#!/bin/bash

FROM ubuntu:14.04.3
RUN apt-get update && apt-get install -y \
  git \
  fakeroot \
  build-essential \
  ncurses-dev xz-utils \
  kernel-package \
  bc \
  autoconf \
  python \
  pkg-config \
  zlibc \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libglib2.0-dev \
  libtool \
  flex \
  bison
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo

#!/bin/bash

FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y sudo
RUN echo "ALL ALL=NOPASSWD: ALL" > /etc/sudoers.d/open-sudo
RUN chmod 0440 /etc/sudoers.d/open-sudo

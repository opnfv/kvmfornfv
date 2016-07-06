#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y ruby-dev rubygems-integration python-pip rpm createrepo dpkg-dev
sudo gem install fpm
sudo pip install fuel-plugin-builder
sudo apt-get install docker.io -y
cd /home/vagrant
# Will build fuel-plugin-kvm in guest VM local directory, not change host
cp -r /kvmfornfv .
cd kvmfornfv/fuel-plugin
fpb --debug --build .
# Copy the built fuel-plugin-kvm back to the host
cp *.rpm /vagrant

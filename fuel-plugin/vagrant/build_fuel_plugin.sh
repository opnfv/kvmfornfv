#!/bin/bash
sudo apt-get update -y
sudo apt-get install createrepo rpm dpkg-dev -y
sudo apt-get install python-setuptools -y
sudo apt-get install python-pip -y
sudo easy_install pip
sudo pip install fuel-plugin-builder
sudo apt-get install ruby -y
sudo gem install rubygems-update
sudo gem install fpm
sudo apt-get install docker.io -y
cd /home/vagrant
# Will build fuel-plugin-kvm in guest VM local directory, not change host
cp -r /kvmfornfv .
cd kvmfornfv/fuel-plugin
fpb --debug --build . 
# Copy the built fuel-plugin-kvm back to the host
rm /kvmfornfv/fuel-plugin/fuel-plugin-kvm*.rpm
cp fuel-plugin-kvm*.rpm /kvmfornfv/fuel-plugin/.

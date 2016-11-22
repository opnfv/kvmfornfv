#!/bin/bash
cd /home/jenkins
source vsperfenv/bin/activate
./vswitchperf/vsperf --list

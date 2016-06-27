#!/bin/bash

choice=$1

case "$choice" in
   "centos"|"")
       echo "Build $choice Rpms"
       cd ci/build_rpm
       ./pre_build_rpm.sh
   ;;
   "ubuntu")
       echo "Build $choice Debians"
       cd ci/build_deb
       ./pre_build_debian.sh
   ;;
   "both")
       echo "Build $choice Debians and Rpms"
       cd ci/build_deb
       ./pre_build_debian.sh
       cd ../build_rpm
       ./pre_build_rpm.sh
   ;;
   *)
       echo "Invalid option"
   ;;
esac

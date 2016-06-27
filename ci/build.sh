#!/bin/bash

choice=$1

case "$choice" in
   "debian") echo "Build debians"
             cd ci/build_deb
             ./pre_build_debian.sh 
   ;;
   "rpm") echo "Build rpms"
          cd ci/build_rpm
          ./pre_build_rpm.sh
   ;;
   *) echo "Default-- Build both debians and rpms"
      cd ci/build_deb
      ./pre_build_debian.sh 
      cd ../build_rpm
      ./pre_build_rpm.sh
   ;;
esac

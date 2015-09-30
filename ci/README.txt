This directory contains scripts for continuous integration of kvmfornfv.

The following scripts are called by Jenkins:
  build.sh  - script to build kvmfornfv kernel
  verify.sh - script to verify the newly built kernel

The following scripts are executed on host system:
  host-config      - host configuration
  host-setup0.sh   - executed after new kernel is installed on host,
                     before host is rebooted
  host-setup1.sh   - executed after host is rebooted, before guest is started
  host-run-qemu.sh - script to start guest

The following scripts are executed on guest system:
  guest-config       - guest configuration
  guest-setup0.sh    - executed after new kernel is installed on guest,
                       before guest is rebooted
  guest-setup1.sh    - executed after guest is rebooted, before running tests
  guest-run-tests.sh - script to run tests on guest

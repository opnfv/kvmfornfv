.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

=====================================
KVM4NFV CICD Installation Instruction
=====================================

Preparing the installation
--------------------------

The OPNFV project- KVM4NFV (https://gerrit.opnfv.org/gerrit/kvmfornfv.git) is
cloned first, to make the build scripts for Qemu & Kernel, Rpms and Debians
available.

HW requirements
---------------

These build scripts are triggered on the Jenkins-Slave build server. Currently
Intel POD1 is used as test environment for kvmfornfv to execute cyclictest. As
part of this test environment Intel pod1-jump is configured as jenkins slave
and all the latest build artifacts are downloaded on to it. Intel pod1-node1
is the host on which a guest vm will be launched as a part of running cylictest
through yardstick.

Installation instructions
-------------------------

* How to build Kernel/Qemu Rpms- To build rpm packages, build.sh script is run
with -p and -o option (i.e. if -p package option is  passed as "centos" or in
default case). Example: sh ./ci/build.sh -p centos -o build_output

* How to build Kernel/Qemu Debians- To build debian packages, build.sh script
is run with -p and -o option (i.e. if -p package option is  passed as "ubuntu")
Example: sh ./ci/build.sh -p ubuntu -o build_output

* How to build all Kernel & Qemu, Rpms & Debians- To build both debian and rpm
packages, build.sh script is run with -p and -o option (i.e. if -p package
option is passed as "both"). Example: sh ./ci/build.sh -p both -o build_output

* Test the built packages by executing the scripts present in ci/envs for host
and guest setup and configuration respectively. Once the setup is in place,
cyclictests are performed via yardtick, using ci/test_kvmfornfv.sh

Post-installation activities
----------------------------

After the rpm and debian builds are deployed successfully on the host-guest and
give the expected cyclictest results, jenkins gives +1 to indicate the
completion of verify process. Thereafter, the releng executes the merge process
to merge this code into parent repository.

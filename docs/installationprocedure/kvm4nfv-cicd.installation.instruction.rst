.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

================================
KVM4NFV Installation Instruction
================================

Preparing the installation
--------------------------

The OPNFV project- KVM4NFV (https://gerrit.opnfv.org/gerrit/kvmfornfv.git) is
cloned first, to make the build scripts for Qemu & Kernel, Rpms and Debians
available.

HW requirements
---------------

These build scripts are triggered on the Jenkins-Slave build server. Currently
Intel POD10 is used as test environment for kvm4nfv to execute cyclictest. As
part of this test environment Intel pod10-jump is configured as jenkins slave
and all the latest build artifacts are downloaded on to it. Intel pod10-node1
is the host on which a guest vm will be launched as a part of running cylictest
through yardstick.

Build instructions
------------------

Builds are possible for the following packages-

**kvmfornfv source code**

The ./ci/build.sh is the main script used to trigger
the Rpms (on 'centos') and Debians (on 'ubuntu') builds in this case.

* How to build Kernel/Qemu Rpms- To build rpm packages, build.sh script is run
  with -p and -o option (i.e. if -p package option is  passed as "centos" or in
  default case). Example:

.. code:: bash

   cd kvmfornfv/

   For Kernel/Qemu RPMs,
   sh ./ci/build.sh -p centos -o build_output

* How to build Kernel/Qemu Debians- To build debian packages, build.sh script
  is run with -p and -o option (i.e. if -p package option is  passed as
  "ubuntu"). Example:

.. code:: bash

   cd kvmfornfv/

   For Kernel/Qemu Debians,
   sh ./ci/build.sh -p ubuntu -o build_output


* How to build all Kernel & Qemu, Rpms & Debians- To build both debian and rpm
  packages, build.sh script is run with -p and -o option (i.e. if -p package
  option is passed as "both"). Example:

.. code:: bash

   cd kvmfornfv/

   For Kernel/Qemu RPMs and Debians,
   sh ./ci/build.sh -p both -o build_output

.. note:: Kvm4nfv can be installed in two ways

          1. As part of a `scenario deployment`_
          2. As a `stand alone`_ component

.. _scenario deployment: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#document-scenarios/kvmfornfv.scenarios.description
.. _stand alone: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#build-instructions

For installation of kvmfornfv as part of scenario deployment use this `link`_

.. code:: bash

   http://artifacts.opnfv.org/kvmfornfv/docs/index.html#document-scenarios/kvmfornfv.scenarios.description


Installation instructions
-------------------------

Installation can be done in the following ways-

**1. From kvmfornfv source code**-
The build packages that are prepared in the above section, are installed
differently depending on the platform.

Please visit the links for each-

* Centos : https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-rpm-using.html
* Ubuntu : https://help.ubuntu.com/community/InstallingSoftware

**2. Using Fuel installer**-

* Please refer to the document present at /fuel-plugin/README.md

Post-installation activities
----------------------------

After the packages are built, test these packages by executing the scripts
present in ci/envs for configuring the host and guest respectively.

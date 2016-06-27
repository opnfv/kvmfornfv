OPNFV KVM4NFV CICD: Scripts for generating Kernel debian and rpm builds
=======================================================================

These scripts will be triggered to build kernel-rpm and kernel-deb
builds inside ubuntu docker, as part of the CICD process. After the
new builds are ready, they will be deployed on the pharos testbed
for verification. Later, these will be consumed/triggered by
verify/daily Releng JJBs.

For more information,
please visit https://wiki.opnfv.org/display/kvm/KVM4NFV+CICD+Jobs


Files Description
-----------------

The files inside kvmfornfv/ci/build_kernel_rpm_deb directory are
used for this feature-

pre_build_hook       -->> It is triggered first by the CICD process
(while Jenkins build) on the Jenkins slave. It creates a docker
container using Dockerfile. After the fresh builds are  generated,
they are copied from the container to this slave VM and stored in
'centos' and 'ubuntu' repositories respectively.

Dockerfile           -->> It is called to create ubuntu docker and
prepare the rpm and debian builds inside it

build_deb_kvm.sh     -->> It is the main file that is called to create
kernel debian builds

build_rpm_kvm.sh     -->> It is the main file that is called to create
kernel rpm builds

build_rpm_package.sh -->> It is called by the Dockerfile to trigger
rpm build creation (using build_rpm_kvm.sh)


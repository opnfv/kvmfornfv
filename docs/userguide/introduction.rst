.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

======================
Userguide Introduction
======================

Overview
--------

The project "NFV Hypervisors-KVM" makes collaborative efforts to enable NFV
features for existing hypervisors, which are not necessarily designed or
targeted to meet the requirements for the NFVI.The KVM4NFV scenario
consists of Continuous Integration builds, deployments and testing
combinations of virtual infrastructure components.

KVM4NFV Features
----------------

Using this project, the following areas are targeted-

* Minimal Interrupt latency variation for data plane VNFs:
   * Minimal Timing Variation for Timing correctness of real-time VNFs
   * Minimal packet latency variation for data-plane VNFs
* Inter-VM communication
* Fast live migration

Some of the above items would require software development and/or specific
hardware features, and some need just configurations information for the
system (hardware, BIOS, OS, etc.).

We include a requirements gathering stage as a formal part of the project.
For each subproject, we will start with an organized requirement stage so
that we can determine specific use cases (e.g. what kind of VMs should be
live migrated) and requirements (e.g. interrupt latency, jitters, Mpps,
migration-time, down-time, etc.) to set out the performance goals.

Potential future projects would include:

* Dynamic scaling (via scale-out) using VM instantiation
* Fast live migration for SR-IOV

The user guide outlines how to work with key components and features in
the platform, each feature description section will indicate the scenarios
that provide the components and configurations required to use it.

The configuration guide details which scenarios are best for you and how to
install and configure them.

General usage guidelines
------------------------

The user guide for KVM4NFV features and capabilities provide step by step
instructions for using features that have been configured according to the
installation and configuration instructions.

Scenarios User Guide
--------------------

The procedure to deploy/test `KVM4NFV scenarios`_ in a nested virtualization
or on bare-metal environment is mentioned in the below link. The kvm4nfv user guide can
be found at docs/scenarios

.. code:: bash

    http://artifacts.opnfv.org/kvmfornfv/docs/index.html#kvmfornfv-scenarios-overview-and-description

.. _KVM4NFV scenarios: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#kvmfornfv-scenarios-overview-and-description

The deployment has been verified for `os-nosdn-kvm-ha`_, os-nosdn-kvm-noha, `os-nosdn-kvm_ovs_dpdk-ha`_,
`os-nosdn-kvm_ovs_dpdk-noha`_ and `os-nosdn-kvm_ovs_dpdk_bar-ha`_, `os-nosdn-kvm_ovs_dpdk_bar-noha`_ test scenarios.

For brief view of the above scenarios use:

.. code:: bash

  http://artifacts.opnfv.org/kvmfornfv/docs/index.html#scenario-abstract

.. _os-nosdn-kvm-ha: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#kvmfornfv-scenarios-overview-and-description

.. _os-nosdn-kvm_ovs_dpdk-ha: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#os-nosdn-kvm-nfv-ovs-dpdk-ha-overview-and-description

.. _os-nosdn-kvm_ovs_dpdk-noha: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#os-nosdn-kvm-nfv-ovs-dpdk-noha-overview-and-description

.. _os-nosdn-kvm_ovs_dpdk_bar-ha: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#os-nosdn-kvm-nfv-ovs-dpdk_bar-ha-overview-and-description

.. _os-nosdn-kvm_ovs_dpdk_bar-noha: http://artifacts.opnfv.org/kvmfornfv/docs/index.html#os-nosdn-kvm-nfv-ovs-dpdk_bar-noha-overview-and-description

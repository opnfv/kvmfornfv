.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) OPNFV, Intel Corporation, AT&T and others.

======================
Kvmfornfv Requirements
======================

Introduction
------------
The NFV hypervisors provide crucial functionality in the NFV
Infrastructure(NFVI).The existing hypervisors, however, are not necessarily
designed or targeted to meet the requirements for the NFVI.

This document specifies the list of requirements that need to be met as part
of this "NFV Hypervisors-KVM" project in Danube release.

As part of this project we need to make collaborative efforts towards enabling
the NFV features.


Scope and Purpose
-----------------

The main purpose of this project is to enhance the KVM hypervisor for NFV, by
looking at the following areas initially:

* Minimal Interrupt latency variation for data plane VNFs:
   * Minimal Timing Variation for Timing correctness of real-time VNFs
   * Minimal packet latency variation for data-plane VNFs
* Inter-VM communication
* Fast live migration

The output of this project would be list of the performance goals,comprehensive
instructions for the system configurations,tools to measure Performance and
interrupt latency.

Methods and Instrumentation
---------------------------

The above areas would require software development and/or specific hardware
features, and some need just configurations information for the system
(hardware, BIOS, OS, etc.).

A right configuration is critical for improving the NFV performance/latency.
Even working on the same code base, different configurations can make
completely different performance/latency result.
Configurations that can be made as part of this project to tune a specific
scenario are:

 1. **Platform Configuration** : Some hardware features like Power management,
    Hyper-Threading,Legacy USB Support/Port 60/64 Emulation,SMI can be configured.
 2. **Operating System Configuration** : Some configuration features like CPU
    isolation,Memory allocation,IRQ affinity,Device assignment for VM,Tickless,
    TSC,Idle,_RCU_NOCB_,Disable the RT throttling,NUMA can be configured.
 3. **Performance/Latency Tuning** : Application level configurations like
    timers,Making vfio MSI interrupt as non-threaded,Cache Allocation
    Technology(CAT) enabling can be tuned to improve the NFV
    performance/latency.

Features to be tested
---------------------

The tests that need to be conducted to make sure that latency is addressed are:
 1. Timer test
 2. Device Interrupt Test
 3. Packet forwarding (DPDK OVS)
 4. Packet Forwarding (SR-IOV)
 5. Bare-metal Packet Forwarding

Dependencies
------------

1. OPNFV Project: “Characterize vSwitch Performance for Telco NFV Use Cases”
   (VSPERF) for performance evaluation of ivshmem vs. vhost-user.
2. OPNFV Project: “Pharos” for Test Bed Infrastructure, and possibly
   “Yardstick” for infrastructure verification.
3. There are currently no similar projects underway in OPNFV or in an upstream
   project
4. The relevant upstream project to be influenced here is QEMU/KVM and
   libvirt.
5. In terms of HW dependencies, the aim is to use standard IA Server hardware
   for this project, as provided by OPNFV Pharos.


Reference
---------

https://wiki.opnfv.org/display/kvm/

===============
KVM4NFV project
===============

Welcome to KVM4NFV_ project!



.. _KVM4NFV: https://wiki.opnfv.org/nfv-kvm

Contents:

KVM4NFV Project Description
===========================

The NFV hypervisors provide crucial functionality in the NFV Infrastructure
(NFVI). The existing hypervisors, however, are not necessarily designed or
targeted to meet the requirements for the NFVI, and we need to make
collaborative efforts toward enabling the NFV features.

The KVM4NFV project focuses on the KVM hypervisor to enhance it for NFV, by
looking at the following areas

+ Minimal Interrupt latency variation for data plane VNFs
    * Minimal Timing Variation for Timing correctness of real-time VNFs
    * Minimal packet latency variation for data-plane VNFs
+ Fast live migration

These items requires software development and/or specific hardware features,
and some needed just configurations information for the system (hardware, BIOS,
OS, etc.).

.. toctree::
        :numbered:
        :maxdepth: 1

Setup Guides
============
.. toctree::
        :maxdepth: 2

        environment-setup
        tunning
        live_migration

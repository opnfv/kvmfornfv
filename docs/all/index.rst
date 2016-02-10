.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) <optionally add copywriters name>

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

While these items require software development and/or specific hardware features
there are also some adjustments that need to be made to system configuration
information, like hardware, BIOS, OS, etc.

.. toctree::
        :numbered:
        :maxdepth: 1

Setup Guides
============
.. toctree::
        :maxdepth: 2

        environment-setup
        tuning
        live_migration


.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

========================
KVM4NFV Project Overview
========================

Project Purpose
---------------
**Purpose:**

  ``This document provides an overview of the areas that can be addressed to
  enhance the KVM Hypervisor for NFV. It is intended to capture and convey the
  significant changes which have been made on the KVM Hypervisor.``

Project Description
-------------------
The NFV hypervisors provide crucial functionality in the NFV
Infrastructure(NFVI).The existing hypervisors, however, are not necessarily
designed or targeted to meet the requirements for the NFVI.

This design focuses on the enhancement of following area for KVM Hypervisor

* Minimal Interrupt latency variation for data plane VNFs:
   * Minimal Timing Variation for Timing correctness of real-time VNFs
   * Minimal packet latency variation for data-plane VNFs
* Fast live migration

The detailed understanding of this project is organized into different sections-

* **installation procedure** - This will give the user instructions on how to deploy
  available KVM4NFV build scenario.
* **design** - This includes the parameters or design considerations taken into
  account for achieving minimal interrupt latency for the data VNFs.
* **requirements** - This includes the introduction of KVM4NFV project,
  specifications of how the project should work, and constraints placed upon
  its execution.
* **configuration guide** - This provides guidance for configuring KVM4NFV
  environment, even with the use of specific installer tools for deploying some
  components, available in the Euphrates release of OPNFV.
* **scenarios** - This includes the sceanrios that are currently implemented in the
  kvm4nfv project,features of each scenario and a general guide to how to deploy them.
* **userguide** - This provides the required technical assistance to the user, in
  using the KVM4NFV process.
* **release notes** - This describes a brief summary of recent changes, enhancements
  and bug fixes in the KVM4NFV project.
* **glossary** - It includes the definition of terms, used in the KVM4NFV project.

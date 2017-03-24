.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _Kvmfornfv: https://wiki.opnfv.org/display/kvm/

=============
Release Notes
=============

Abstract
---------

This document provides the release notes for Danube 1.0 release of KVM4NFV.


**Contents**

 **1  Version History**

 **2  Important notes**

 **3  Summary**

 **4  Delivery Data**

 **5  References**

Version history
---------------

+--------------------+--------------------+--------------------+----------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**          |
|                    |                    |                    |                      |
+--------------------+--------------------+--------------------+----------------------+
|2016-08-22          | 0.1.0              |                    | Colorado 1.0 release |
|                    |                    |                    |                      |
+--------------------+--------------------+--------------------+----------------------+
|2017-03-27          | 0.1.0              |                    | Danube 1.0 release   |
|                    |                    |                    |                      |
+--------------------+--------------------+--------------------+----------------------+

Important notes
---------------

The KVM4NFV project is currently supported on the Fuel installer.

Summary
-------

This Danube 1.0 release provides *KVM4NFV* as a framework to enhance the
KVM Hypervisor for NFV and OPNFV scenario testing, automated in the OPNFV
CI pipeline, including:

*   KVMFORNFV source code

*   Automation of building the Kernel and qemu for RPM and debian packages

*   Cyclictests execution to check the latency

*   “os-nosdn-kvm-ha”,“os-nosdn-kvm_nfv_ovs_dpdk-ha”,“os-nosdn-kvm_nfv_ovs_dpdk-noha”,“os-nosdn-kvm_nfv_ovs_dpdk_bar-ha”,
    “os-nosdn-kvm_nfv_ovs_dpdk_bar-noha” Scenarios testing for ``high availability/no-high avaliability``
    configuration using Fuel installer

* Documentation created for,

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Release notes

  * Scenarios Guide

  * Design Guide

  * Requirements Guide

The *KVM4NFV framework* is developed in the OPNFV community, by the
KVM4NFV_ team.

Release Data
------------

+--------------------------------------+--------------------------------------+
| **Project**                          | NFV Hypervisors-KVM                  |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/commit-ID**                   | kvmfornfv                            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Danube                               |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | 2017-03-27                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Danube 1.0 Releases            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Version change
--------------

1   Module version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the Danube 1.0 main release. It is based on following upstream
versions:

*   RT Kernel 4.4.50-rt62

*   QEMU 2.6

*   Fuel plugin based on Fuel 10.0

This is the second tracked release of KVM4NFV


2   Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the second version of the KVM4NFV framework in OPNFV.

Reason for version
------------------

1 Feature additions
~~~~~~~~~~~~~~~~~~~

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-57         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-58         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-59         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-61         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-62         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-63         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-64         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-65         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

A brief ``Description of the the JIRA tickets``:

+---------------------------------------+-------------------------------------------------------------+
| **JIRA REFERENCE**                    | **DESCRIPTION**                                             |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-57                          | CI/CD Integration into Yardstick                            |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-58                          | Complete the integration of test plan into Yardstick        |
|                                       | and Jenkins infrastructure to include latency testing       |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-59                          | Enable capability to publish results on Yardstick Dashboard |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-61                          | Define and integrate additional scenario - KVM+OVS+DPDK     |
|                                       | with HA and NOHA for baremetal and virtual environments     |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-62                          | Define and integrate additional scenario - KVM+OVS+DPDK+BAR |
|                                       | with HA and NOHA for bare metal and virtual environments    |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-63                          | Setup Local fuel environment                                |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-64                          | Fuel environment setup for local machine to debug Fuel      |
|                                       | related integration issues                                  |
+---------------------------------------+-------------------------------------------------------------+

Deliverables
------------

1   Software deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~
* Danube 1.0 release of the KVM4NFV RPM and debian for kvm4nfv

* Added the following scenarios as part of D-Release:

  * os-nosdn-kvm_nfv_ovs_dpdk-noha

  * os-nosdn-kvm_nfv_ovs_dpdk_bar-noha

  * os-nosdn-kvm_nfv_ovs_dpdk-ha

  * os-nosdn-kvm_nfv_ovs_dpdk_bar-ha

* Configured influxdb and `Graphana dashboard`_ for publishing kvm4nfv test results

.. _Graphana_dashboard: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest

* Cyclictest test case is successfully implemented, it has the below test types.,

  * idle-idle

  * CPUstress-idle

  * IOstress-idle

  * Memorystress-idle

* Implemented Noisy Neighbour feature ., cyclictest under stress testing is implemented

* Packet forwarding test case is implemented and it supports the following test types currently,

  * Packet forwarding to Host

  * Packet forwarding to Guest

  * Packet forwarding to Guest using SRIOV

* Ftrace debugging tool is supported in D-Release. The logs collected by ftrace are stored in artifacts for future needs

* PCM Utility is part of D-Release. The future scope may include collection of read/write data and publishing in grafana

* Either Apex or Fuel can be used for deployment of os-nosdn-kvm-ha scenario

+------------------------------------------+------------------+-----------------+
| **Scenario Name**                        | **Apex**         | **Fuel**        |
|                                          |                  |                 |
+==========================================+==================+=================+
| - os-nosdn-kvm-ha                        |     ``Y``        |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_nfv_ovs_dpdk-noha         |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_nfv_ovs_dpdk-ha           |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_nfv_ovs_dpdk_bar-noha     |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_nfv_ovs_dpdk_bar-ha       |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+

* Future scope may include adding Apex support for all the remaining scenarios

* The below documents are delivered for Danube KVM4NFV Release:

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Overview

  * Release notes

  * Glossary

  * Scenarios

  * Requirements Guide

  * Overview Guide

References
----------

For more information on the KVM4NFV Danube release, please see:

https://wiki.opnfv.org/display/kvm/

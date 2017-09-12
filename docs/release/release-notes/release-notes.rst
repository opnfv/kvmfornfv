.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _Kvmfornfv: https://wiki.opnfv.org/display/kvm/

=============
Release Notes
=============

Abstract
---------

This document provides the release notes for Euphrates 1.0 release of KVM4NFV.


**Contents**

 **1  Version History**

 **2  Important notes**

 **3  Summary**

 **4  Delivery Data**

 **5  References**

Version history
---------------

+--------------------+--------------------+--------------------+------------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**            |
|                    |                    |                    |                        |
+--------------------+--------------------+--------------------+------------------------+
|2016-08-22          | 0.1.0              |                    | Colorado 1.0 release   |
|                    |                    |                    |                        |
+--------------------+--------------------+--------------------+------------------------+
|2017-03-27          | 0.1.0              |                    | Danube 1.0 release     |
|                    |                    |                    |                        |
+--------------------+--------------------+--------------------+------------------------+
|2017-10-06          | 0.1.0              |                    | Euphrates 1.0 release  |
|                    |                    |                    |                        |
+--------------------+--------------------+--------------------+------------------------+

Important notes
---------------

The KVM4NFV project is currently supported on Fuel and Apex installer.

Summary
-------

This Euphrates 1.0 release provides *KVM4NFV* as a framework to enhance the
KVM Hypervisor for NFV and OPNFV scenario testing, automated in the OPNFV
CI pipeline, including:

*   KVMFORNFV source code

*   Automation of building the Kernel and qemu for RPM and debian packages

*   Cyclictests execution to check the latency

*   “os-nosdn-kvm_ovs_dpdk-ha”,“os-nosdn-kvm_ovs_dpdk-noha”, Scenarios testing for
    ``high availability/no-high avaliability`` configuration using Apex installer

* Documentation created for,

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Release notes

  * Scenarios Guide

  * Design Guide

  * Requirements Guide


Release Data
------------

+--------------------------------------+--------------------------------------+
| **Project**                          | NFV Hypervisors-KVM                  |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/commit-ID**                   | kvmfornfv                            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Euphrates                            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | 2017-10-06                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Euphrates 1.0 Releases         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

Version change
--------------

1   Module version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the Euphrates 1.0 main release. It is based on following upstream
versions:

*   RT Kernel 4.4.50-rt62

*   QEMU 2.9.0

*   Apex based on Openstack Ocata


This is the third tracked release of KVM4NFV


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
| JIRA:                                | NFV Hypervisors-KVMFORNFV-72         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-73         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-78         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-86         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-87         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-88         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMFORNFV-89         |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | VSPERF-510                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | YARDSTICK-783                        |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | YARDSTICK-815                        |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

A brief ``Description of the the JIRA tickets``:

+---------------------------------------+-------------------------------------------------------------+
| **JIRA REFERENCE**                    | **DESCRIPTION**                                             |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-72                          | Define and integrate additional scenario - KVM+OVS+DPDK     |
|                                       | with HA for bare metal and virtual environments             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-73                          | Define and integrate additional scenario - KVM+OVS+DPDK     |
|                                       | with NOHA for bare metal and virtual environments           |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-78                          | Scenarios in Euphrates release for KVM for NFV              |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-86                          | Live Migration tests in kvmfornfv repository                |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-87                          | Packet forwarding test type pxp - multiple guests           |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-88                          | Apex environment setup for local machine to debug Apex      |
|                                       | related integration issues                                  |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| KVMFORNFV-89                          | Generate kernel debug-info rpm                              |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| VSPERF-510                            | KVM optimizations                                           |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+
| YARDSTICK-783                         | To update Grafana dashboard for kvmfornfv packet forwarding |
|                                       | test cases                                                  |
+---------------------------------------+-------------------------------------------------------------+
| YARDSTICK-815                         | Implementation of breaktrace option for cyclictest          |
|                                       |                                                             |
+---------------------------------------+-------------------------------------------------------------+

Deliverables
------------

1   Software deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~
* Euphrates 1.0 release of the KVM4NFV RPM and debian for kvm4nfv

* Kernel debug-info rpm and debian is generated as part of E-release

* Integrated the following scenarios in APEX as part of E-Release:

  * os-nosdn-kvm_ovs_dpdk-noha

  * os-nosdn-kvm_ovs_dpdk-ha

* Configured influxdb and `Graphana_dashboard`_ for publishing kvm4nfv test results

.. _Graphana_dashboard: http://testresults.opnfv.org/grafana/dashboard/db/kvmfornfv-cyclictest

* Packet forwarding test case is implemented and it supports the following test types currently,

  * Packet forwarding to Host

  * Packet forwarding to Guest

  * Packet forwarding to Guest using SRIOV
  
  * Packet forwarding to multiple guests

* Breaktrace option is implemented to monitor the latency values obatined by the cyclictest

* Live Migration test case is implemented and the following values are collected:

  * Total time
  
  * Down time
  
  * Setup time 

* Either Apex or Fuel can be used for deployment of os-nosdn-kvm-ha, os-nosdn-kvm_ovs_dpdk-ha and
os-nosdn-kvm_ovs_dpdk-noha scenarios

+------------------------------------------+------------------+-----------------+
| **Scenario Name**                        | **Apex**         | **Fuel**        |
|                                          |                  |                 |
+==========================================+==================+=================+
| - os-nosdn-kvm-ha                        |     ``Y``        |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_ovs_dpdk-noha             |     ``Y``        |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_ovs_dpdk-ha               |     ``Y``        |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_ovs_dpdk_bar-noha         |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+
| - os-nosdn-kvm_ovs_dpdk_bar-ha           |                  |     ``Y``       |
+------------------------------------------+------------------+-----------------+

* The below documents are delivered for Euphrates KVM4NFV Release:

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

For more information on the KVM4NFV Euphrates release, please see:

https://wiki.opnfv.org/display/kvm/

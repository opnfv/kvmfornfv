.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0

.. _Kvmfornfv: https://wiki.opnfv.org/display/kvm/

=============
Release Notes
=============

Abstract
---------

This document provides the release notes for Danube 1.0 release of KVMFORNFV.


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

The KVMFORNFV project is currently supported on the Fuel installer.

Summary
-------

This Danube 1.0 release provides *KVMFORNFV* as a framework to enhance the
KVM Hypervisor for NFV and OPNFV scenario testing, automated in the OPNFV
CI pipeline, including:

*   KVMFORNFV source code

*   Automation of building the Kernel and qemu for RPM and debian packages

*   Cyclictests execution to check the latency

*   “os-nosdn-kvm-ha”,“os-nosdn-kvm_nfv_ovs_dpdk-ha”,“os-nosdn-kvm_nfv_ovs_dpdk-noha”,“os-nosdn-kvm_nfv_ovs_dpdk_bar-ha”,“os-nosdn-kvm_nfv_ovs_dpdk_bar-noha” Scenarios testing for ``high availability/no-high avaliability`` configuration using Fuel installer

* Documentation created for,

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Release notes (this document)

  * Scenarios

The *KVMFORNFV framework* is developed in the OPNFV community, by the
KVMFORNFV_ team.

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

This is the second tracked release of KVMFORNFV


2   Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the initial version of the KVMFORNFV framework in OPNFV.

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

2 Bug corrections
~~~~~~~~~~~~~~~~~

Initial Release

Deliverables
------------

1   Software deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~
Danube 1.0 release of the KVMFORNFV RPM and debian for Fuel.

2   Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The below documents are delivered for Danube KVMFORNFV Release:

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Overview

  * Release notes (this document)

  * Glossary

  * Scenarios

References
----------

For more information on the KVMFORNFV Danube release, please see:

https://wiki.opnfv.org/display/kvm/

.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

=====================================================
OPNFV Release Note for "Colorado release" - KVMFORNFV
=====================================================

.. _Kvmfornfv: https://wiki.opnfv.org/display/kvm/


Abstract
========

This document provides the release notes for Colorado release of KVMFORNFV.

License
=======

KVMFORNFV is licensed under a Creative Commons Attribution 4.0 International
License.You should have received a copy of the license along with this. If not,
see <http://creativecommons.org/licenses/by/4.0/>.


**Contents**

1  Version History

2  Important notes

3  Summary

4  Delivery Data

5 References

1   Version history
===================

+--------------------+--------------------+--------------------+--------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+
|2016-08-22          | 0.1.0              |                    | Colorado release   |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+

2   Important notes
===================

The software delivered in the OPNFV KVMFORNFV_ Project, comprises the
*ci*, the *kvmfornfv test cases*.

The *KVMFORNFV* framework depends on the *Fuel* installer.


3   Summary
===========

This Colorado release provides *KVMFORNFV* as a framework to enhance the
KVM Hypervisor for NFV and OPNFV scenario testing, automated in the OPNFV
CI pipeline, including:

* Documentation created

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Release notes (this document)

* KVMFORNFV source code

* Cyclictests for KVMFORNFV

For Colorado release, the KVMFORNFV uses for the following:

* Automation of building the Kernel and qemu RPM's or debians

* Executing the Cyclictests to check the latency

* os-sdn-kvm-ha Scenario testing for High Availability Configuration using
  Fuel Installer

The *KVMFORNFV framework* is developed in the OPNFV community, by the
KVMFORNFV_ team.

4   Release Data
================

+--------------------------------------+--------------------------------------+
| **Project**                          | NFV Hypervisors-KVM                  |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Repo/commit-ID**                   | kvmfornfv                            |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release designation**              | Colorado                             |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Release date**                     | 2016-08-22                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Colorado Releases              |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

4.1 Version change
------------------

4.1.1   Module version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the first tracked release of KVMFORNFV


4.1.2   Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the initial version of the KVMFORNFV framework in OPNFV.

4.2 Reason for version
----------------------

4.2.1 Feature additions
~~~~~~~~~~~~~~~~~~~~~~~

+--------------------------------------+--------------------------------------+
| **JIRA REFERENCE**                   | **SLOGAN**                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMKVMFORNFV-34      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| JIRA:                                | NFV Hypervisors-KVMKVMFORNFV-34      |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

4.2.2 Bug corrections
~~~~~~~~~~~~~~~~~~~~~

Initial Release

4.3 Deliverables
----------------

4.3.1   Software deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KVMFORNFV framework source code <Colorado>

4.3.2   Documentation deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The below documents are delivered for Colorado KVMFORNFV Release:

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Overview

  * Release notes (this document)

  * Glossary


5  References
=============

For more information on the KVMFORNFV Colorado release, please see:

https://wiki.opnfv.org/display/kvm/

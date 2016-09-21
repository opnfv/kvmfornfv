.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. http://creativecommons.org/licenses/by/4.0
.. (c) <optionally add copywriters name>


.. _Kvmfornfv: https://wiki.opnfv.org/display/kvm/


Abstract
========

This document provides the release notes for Colorado 1.0 release of KVMFORNFV.


**Contents**

1  Version History

2  Important notes

3  Summary

4  Delivery Data

5  References

1   Version history
===================

+--------------------+--------------------+--------------------+----------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**          |
|                    |                    |                    |                      |
+--------------------+--------------------+--------------------+----------------------+
|2016-08-22          | 0.1.0              |                    | Colorado 1.0 release |
|                    |                    |                    |                      |
+--------------------+--------------------+--------------------+----------------------+

2   Important notes
===================

The KVMFORNFV project is currently supported on the Fuel installer.

3   Summary
===========

This Colorado 1.0 release provides *KVMFORNFV* as a framework to enhance the
KVM Hypervisor for NFV and OPNFV scenario testing, automated in the OPNFV
CI pipeline, including:

*   KVMFORNFV source code

*   Automation of building the Kernel and qemu for RPM and debian packages

*   Cyclictests execution to check the latency

*   “os-sdn-kvm-ha” Scenario testing for high availability configuration using
Fuel installer

* Documentation created

  * User Guide

  * Configuration Guide

  * Installation Procedure

  * Release notes (this document)

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
| **Release date**                     | 2016-09-22                           |
|                                      |                                      |
+--------------------------------------+--------------------------------------+
| **Purpose of the delivery**          | OPNFV Colorado 1.0 Releases          |
|                                      |                                      |
+--------------------------------------+--------------------------------------+

4.1 Version change
------------------

4.1.1   Module version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is the Colorado 1.0 main release. It is based on following upstream
versions:

*   RT Kernel 4.4.6-rt14

*   QEMU 2.6

*   Fuel plugin based on Fuel 9.0

This is the first tracked release of KVMFORNFV


4.1.2   Document version changes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This is the initial version of the KVMFORNFV framework in OPNFV.

4.2 Reason for version
----------------------

4.2.1 Feature additions
~~~~~~~~~~~~~~~~~~~~~~~

4.2.2 Bug corrections
~~~~~~~~~~~~~~~~~~~~~

Initial Release

4.3 Deliverables
----------------

4.3.1   Software deliverables
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Colorado 1.0 release of the KVMFORNFV RPM and debian for Fuel.

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

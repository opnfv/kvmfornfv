.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

Low Latency Environment
=======================

Achieving low latency with the KVM4NFV project requires setting up a special
test environment. This environment includes the BIOS settings, kernel
configuration, kernel parameters and the run-time environment.

Hardware Environment Description
--------------------------------

BIOS setup plays an important role in achieving real-time latency. A collection
of relevant settings, used on the platform where the baseline performance data
was collected, is detailed below:

CPU Features
~~~~~~~~~~~~

Some special CPU features like TSC-deadline timer, invariant TSC and Process
posted interrupts, etc, are helpful for latency reduction.

CPU Topology
~~~~~~~~~~~~

NUMA topology is also important for latency reduction.

BIOS Setup
~~~~~~~~~~

Careful BIOS setup is important in achieving real time latency. Different
platforms have different BIOS setups, below are the important BIOS settings on
the platform used to collect the baseline performance data.

Software Environment Setup
--------------------------
Both the host and the guest environment need to be configured properly to
reduce latency variations.  Below are some suggested kernel configurations.
The ci/envs/ directory gives detailed implementation on how to setup the
environment.

Kernel Parameter
~~~~~~~~~~~~~~~~

Please check the default kernel configuration in the source code at:
kernel/arch/x86/configs/opnfv.config.

Below is host kernel boot line example:
::
isolcpus=11-15,31-35 nohz_full=11-15,31-35 rcu_nocbs=11-15,31-35
iommu=pt intel_iommu=on default_hugepagesz=1G hugepagesz=1G mce=off idle=poll
intel_pstate=disable processor.max_cstate=1 pcie_asmp=off tsc=reliable

Below is guest kernel boot line example
::
isolcpus=1 nohz_full=1 rcu_nocbs=1 mce=off idle=poll default_hugepagesz=1G
hugepagesz=1G

Please refer to `tuning.userguide` for more explanation.

Run-time Environment Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~

Not only are special kernel parameters needed but a special run-time
environment is also required. Please refer to `tunning.userguide` for
more explanation.

Test cases to measure Latency
=============================

Cyclictest case
---------------

Understanding the naming convention
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Idle-Idle test-type
~~~~~~~~~~~~~~~~~~~

CPU_Stress-Idle test-type
-------------------------

Memory_Stress-Idle test-type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IO_Stress-Idle test-type
~~~~~~~~~~~~~~~~~~~~~~~~

CPU_Stress-CPU_Stress test-type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Memory_Stress-Memory_Stress test-type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

IO_Stress-IO_Stress test type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Packet Forwarding Test case
---------------------------

Packet forwarding to Host
~~~~~~~~~~~~~~~~~~~~~~~~~

Packet forwarding to Guest
~~~~~~~~~~~~~~~~~~~~~~~~~~

Packet forwarding to Guest using SRIOV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



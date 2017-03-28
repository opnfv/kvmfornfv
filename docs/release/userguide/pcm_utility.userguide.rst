.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

======================
PCM Utility in KVM4NFV
======================

Collecting Memory Bandwidth Information using PCM utility
---------------------------------------------------------
This chapter includes how the PCM utility is used in kvm4nfv
to collect memory bandwidth information

About PCM utility
-----------------
The Intel® Performance Counter Monitor provides sample C++ routines and utilities to estimate the
internal resource utilization of the latest Intel® Xeon® and Core™ processors and gain a significant
performance boost.In Intel PCM toolset,there is a pcm-memory.x tool which is used for observing the
memory traffic intensity

Version Features
-----------------

+-----------------------------+-----------------------------------------------+
|                             |                                               |
|      **Release**            |               **Features**                    |
|                             |                                               |
+=============================+===============================================+
|                             | - In Colorado release,we don't have memory    |
|       Colorado              |   bandwidth information collected through the |
|                             |   cyclic testcases.                           |
|                             |                                               |
+-----------------------------+-----------------------------------------------+
|                             | - pcm-memory.x will be executed before the    |
|       Danube                |   execution of every testcase                 |
|                             | - pcm-memory.x provides the memory bandwidth  |
|                             |   data throughout out the testcases           |
|                             | - used for all test-types (stress/idle)       |
|                             | - Generated memory bandwidth logs are         |
|                             |   published to the KVMFORFNV artifacts        |
+-----------------------------+-----------------------------------------------+

Implementation of pcm-memory.x:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The tool measures the memory bandwidth observed for every channel reporting seperate throughput
for reads from memory and writes to the memory. pcm-memory.x tool tends to report values slightly
higher than the application's own measurement.

Command:

.. code:: bash

    sudo ./pcm-memory.x  [Delay]/[external_program]

Parameters

-   pcm-memory can called with either delay or external_program/application as a parameter

-   If delay is given as 5,then the output will be produced with refresh of every 5 seconds.

-   If external_program is script/application,then the output will produced after the execution of the application or the script passed as a parameter.

**Sample Output:**

 The output produced with default refresh of 1 second.

+---------------------------------------+---------------------------------------+
|             Socket 0                  |             Socket 1                  |
+=======================================+=======================================+
|     Memory Performance Monitoring     |     Memory Performance Monitoring     |
|                                       |                                       |
+---------------------------------------+---------------------------------------+
|    Mem Ch 0: Reads (MB/s): 6870.81    |    Mem Ch 0: Reads (MB/s): 7406.36    |
|              Writes(MB/s): 1805.03    |              Writes(MB/s): 1951.25    |
|    Mem Ch 1: Reads (MB/s): 6873.91    |    Mem Ch 1: Reads (MB/s): 7411.11    |
|              Writes(MB/s): 1810.86    |              Writes(MB/s): 1957.73    |
|    Mem Ch 2: Reads (MB/s): 6866.77    |    Mem Ch 2: Reads (MB/s): 7403.39    |
|              Writes(MB/s): 1804.38    |              Writes(MB/s): 1951.42    |
|    Mem Ch 3: Reads (MB/s): 6867.47    |    Mem Ch 3: Reads (MB/s): 7403.66    |
|              Writes(MB/s): 1805.53    |              Writes(MB/s): 1950.95    |
|                                       |                                       |
|    NODE0 Mem Read (MB/s) :  27478.96  |    NODE1 Mem Read (MB/s) :  29624.51  |
|    NODE0 Mem Write (MB/s):  7225.79   |    NODE1 Mem Write (MB/s):  7811.36   |
|    NODE0 P. Write (T/s)  :  214810    |    NODE1 P. Write (T/s)  :  238294    |
|    NODE0 Memory (MB/s)   :  34704.75  |    NODE1 Memory (MB/s)   :  37435.87  |
+---------------------------------------+---------------------------------------+
|                    - System Read Throughput(MB/s):  57103.47                  |
|                    - System Write Throughput(MB/s):  15037.15                 |
|                    - System Memory Throughput(MB/s):  72140.62                |
+-------------------------------------------------------------------------------+

pcm-memory.x in KVM4NFV:
~~~~~~~~~~~~~~~~~~~~~~~~~~

pcm-memory is a part of KVM4NFV in D release.pcm-memory.x will be executed with delay of 60 seconds
before starting every testcase to monitor the memory traffic intensity which was handled in
collect_MBWInfo function .The memory bandwidth information will be collected into the logs through
the testcase updating every 60 seconds.

   **Pre-requisites:**

   1.Check for the processors supported by PCM .Latest pcm utility version (2.11)support Intel® Xeon® E5 v4 processor family.

   2.Disabling NMI Watch Dog

   3.Installing MSR registers


Memory Bandwidth logs for KVM4NFV can be found `here`_:

.. code:: bash

    http://artifacts.opnfv.org/kvmfornfv.html

.. _here: http://artifacts.opnfv.org/kvmfornfv.html

Details of the function implemented:

In install_Pcm function, it handles the installation of pcm utility and the required prerequisites for pcm-memory.x tool to execute.

.. code:: bash

   $ git clone https://github.com/opcm/pcm
   $ cd pcm
   $ make

In collect_MBWInfo Function,the below command is executed on the node which was collected to the logs
with the timestamp and testType.The function will be called at the begining of each testcase and
signal will be passed to terminate the pcm-memory process which was executing throughout the cyclic testcase.

.. code:: bash

  $ pcm-memory.x 60 &>/root/MBWInfo/MBWInfo_${testType}_${timeStamp}

  where,
  ${testType} = verify (or) daily

Future Scope
------------
PCM information will be added to cyclictest of kvm4nfv in yardstick.

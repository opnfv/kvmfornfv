.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

=====================
FTrace Debugging Tool
=====================

About Ftrace
-------------
Ftrace is an internal tracer designed to find what is going on inside the kernel. It can be used
for debugging or analyzing latencies and performance related issues that take place outside of
user-space. Although ftrace is typically considered the function tracer, it is really a frame
work of several assorted tracing utilities.

    One of the most common uses of ftrace is the event tracing.

**Note:**
- For KVM4NFV, Ftrace is preferred as it is in-built kernel tool
- More stable compared to other debugging tools

Version Features
----------------

+-----------------------------+-----------------------------------------------+
|                             |                                               |
|      **Release**            |               **Features**                    |
|                             |                                               |
+=============================+===============================================+
|                             | - Ftrace Debugging tool is not implemented in |
|       Colorado              |   Colorado release of KVM4NFV                 |
|                             |                                               |
+-----------------------------+-----------------------------------------------+
|                             | - Ftrace aids in debugging the KVM4NFV        |
|       Danube                |   4.4-linux-kernel level issues               |
|                             | - Option to disable if not required           |
+-----------------------------+-----------------------------------------------+
|                             | - Breaktrace option is implemented.           |
|       Euphrates             | - Implemented post-execute script option to   |
|                             |   disable the ftrace when it is enabled.      |
+-----------------------------+-----------------------------------------------+


Implementation of Ftrace
-------------------------
Ftrace uses the debugfs file system to hold the control files as
well as the files to display output.

When debugfs is configured into the kernel (which selecting any ftrace
option will do) the directory /sys/kernel/debug will be created. To mount
this directory, you can add to your /etc/fstab file:

.. code:: bash

 debugfs       /sys/kernel/debug          debugfs defaults        0       0

Or you can mount it at run time with:

.. code:: bash

 mount -t debugfs nodev /sys/kernel/debug

Some configurations for Ftrace are used for other purposes, like finding latency or analyzing the system. For the purpose of debugging, the kernel configuration parameters that should be enabled are:

.. code:: bash

    CONFIG_FUNCTION_TRACER=y
    CONFIG_FUNCTION_GRAPH_TRACER=y
    CONFIG_STACK_TRACER=y
    CONFIG_DYNAMIC_FTRACE=y

The above parameters must be enabled in /boot/config-4.4.0-el7.x86_64 i.e., kernel config file for ftrace to work. If not enabled, change the parameter to ``y`` and run.,

.. code:: bash

    On CentOS
    grub2-mkconfig -o /boot/grub2/grub.cfg
    sudo reboot

Re-check the parameters after reboot before running ftrace.

Files in Ftrace:
----------------
The below is a list of few major files in Ftrace.

  ``current_tracer:``

        This is used to set or display the current tracer that is configured.

  ``available_tracers:``

        This holds the different types of tracers that have been compiled into the kernel. The tracers listed here can be configured by echoing their name into current_tracer.

  ``tracing_on:``

        This sets or displays whether writing to the tracering buffer is enabled. Echo 0 into this file to disable the tracer or 1 to enable it.

  ``trace:``

        This file holds the output of the trace in a human readable format.

  ``tracing_cpumask:``

        This is a mask that lets the user only trace on specified CPUs. The format is a hex string representing the CPUs.

  ``events:``

        It holds event tracepoints (also known as static tracepoints) that have been compiled into the kernel. It shows what event tracepoints exist and how they are grouped by system.


Avaliable Tracers
-----------------

Here is the list of current tracers that may be configured based on usage.

- function
- function_graph
- irqsoff
- preemptoff
- preemptirqsoff
- wakeup
- wakeup_rt

Brief about a few:

  ``function:``

        Function call tracer to trace all kernel functions.

  ``function_graph:``

        Similar to the function tracer except that the function tracer probes the functions on their entry whereas the function graph tracer traces on both entry and exit of the functions.

  ``nop:``

        This is the "trace nothing" tracer. To remove tracers from tracing simply echo "nop" into current_tracer.

Examples:

.. code:: bash


     To list available tracers:
     [tracing]# cat available_tracers
     function_graph function wakeup wakeup_rt preemptoff irqsoff preemptirqsoff nop

     Usage:
     [tracing]# echo function > current_tracer
     [tracing]# cat current_tracer
     function

     To view output:
     [tracing]# cat trace | head -10

     To Stop tracing:
     [tracing]# echo 0 > tracing_on

     To Start/restart tracing:
     [tracing]# echo 1 > tracing_on;


Ftrace in KVM4NFV
-----------------
Ftrace is part of KVM4NFV D-Release. KVM4NFV built 4.4-linux-Kernel will be tested by
executing cyclictest and analyzing the results/latency values (max, min, avg) generated.
Ftrace (or) function tracer is a stable kernel inbuilt debugging tool which tests real time
kernel and outputs a log as part of the code. These output logs are useful in following ways.

    - Kernel Debugging.
    - Helps in Kernel code optimization and
    - Can be used to better understand the kernel level code flow

Ftrace logs for KVM4NFV can be found `here`_:


.. _here: http://artifacts.opnfv.org/kvmfornfv.html

Ftrace Usage in KVM4NFV Kernel Debugging:
-----------------------------------------
Kvm4nfv has two scripts in /ci/envs to provide ftrace tool:

    - enable_trace.sh
    - disable_trace.sh

.. code:: bash

    Found at.,
    $ cd kvmfornfv/ci/envs

Enabling Ftrace in KVM4NFV
--------------------------

The enable_trace.sh script is triggered by changing ftrace_enable value in test_kvmfornfv.sh
script to 1 (which is zero by default). Change as below to enable Ftrace.

.. code:: bash

    ftrace_enable=1

Note:

- Ftrace is enabled before

Details of enable_trace script
------------------------------

- CPU coremask is calculated using getcpumask()
- All the required events are enabled by,
   echoing "1" to $TRACEDIR/events/event_name/enable file

Example,

.. code:: bash

   $TRACEDIR = /sys/kernel/debug/tracing/
   sudo bash -c "echo 1 > $TRACEDIR/events/irq/enable"
   sudo bash -c "echo 1 > $TRACEDIR/events/task/enable"
   sudo bash -c "echo 1 > $TRACEDIR/events/syscalls/enable"

The set_event file contains all the enabled events list

- Function tracer is selected. May be changed to other avaliable tracers based on requirement

.. code:: bash

   sudo bash -c "echo function > $TRACEDIR/current_tracer

- When tracing is turned ON by setting ``tracing_on=1``,  the ``trace`` file keeps getting append with the traced data until ``tracing_on=0`` and then ftrace_buffer gets cleared.

.. code:: bash

    To Stop/Pause,
    echo 0 >tracing_on;

    To Start/Restart,
    echo 1 >tracing_on;

- Once tracing is disabled, disable_trace.sh script is triggered.

BREAKTRACE
----------
- Send break trace command when latency > USEC. This is a debugging option to control the latency tracer in the realtime preemption patch. It
is useful to track down unexpected large latencies on a system. This option does only work with following kernel config options.

For kernel < 2.6.24:
* CONFIG_PREEMPT_RT=y
* CONFIG_WAKEUP_TIMING=y
* CONFIG_LATENCY_TRACE=y
* CONFIG_CRITICAL_PREEMPT_TIMING=y
* CONFIG_CRITICAL_IRQSOFF_TIMING=y

For kernel >= 2.6.24:
* CONFIG_PREEMPT_RT=y
* CONFIG_FTRACE
* CONFIG_IRQSOFF_TRACER=y
* CONFIG_PREEMPT_TRACER=y
* CONFIG_SCHED_TRACER=y
* CONFIG_WAKEUP_LATENCY_HIST

- Kernel configuration options enabled. The USEC parameter to the -b option defines a maximum latency value,
which is compared against the actual latencies of the test. Once the measured latency is higher than the given maximum,
the kernel tracer and cyclictest is stopped. The trace can be read from /proc/latency_trace. Please be aware that the
tracer adds significant overhead to the kernel, so the latencies will be much higher than on a kernel with latency tracing disabled.

Post-execute scripts
--------------------
post-execute script to yardstick node context teardown is added to disable the ftrace soon after the completion of cyclictest execution throughyardstick.
This option is implemented to collect only required ftrace logs for effective debugging if needed.

Details of disable_trace Script
-------------------------------
In disable trace script the following are done:

- The trace file is copied and moved to /tmp folder based on timestamp
- The current tracer file is set to ``nop``
- The set_event file is cleared i.e., all the enabled events are disabled
- Kernel Ftrace is disabled/unmounted


Publishing Ftrace logs:
-----------------------
The generated trace log is pushed to `artifacts`_ by kvmfornfv-upload-artifact.sh
script available in releng which will be triggered as a part of kvm4nfv daily job.
The `trigger`_ in the script is.,

.. code:: bash

   echo "Uploading artifacts for future debugging needs...."
   gsutil cp -r $WORKSPACE/build_output/log-*.tar.gz $GS_LOG_LOCATION > $WORKSPACE/gsutil.log 2>&1

.. _artifacts: https://artifacts.opnfv.org/

.. _trigger: https://gerrit.opnfv.org/gerrit/gitweb?p=releng.git;a=blob;f=jjb/kvmfornfv/kvmfornfv-upload-artifact.sh;h=56fb4f9c18a83c689a916dc6c85f9e3ddf2479b2;hb=HEAD#l53

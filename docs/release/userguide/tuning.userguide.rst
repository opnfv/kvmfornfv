.. This work is licensed under a Creative Commons Attribution 4.0 International License.

.. http://creativecommons.org/licenses/by/4.0

Low Latency Tunning Suggestion
==============================

The correct configuration is critical for improving the NFV
performance/latency.Even working on the same codebase, configurations can cause
wildly different performance/latency results.

There are many combinations of configurations, from hardware configuration to
Operating System configuration and application level configuration. And there
is no one simple configuration that works for every case. To tune a specific
scenario, it's important to know the behaviors of different configurations and
their impact.

Platform Configuration
----------------------

Some hardware features can be configured through firmware interface(like BIOS)
but others may not be configurable (e.g. SMI on most platforms).

* **Power management:**
  Most power management related features save power at the
  expensive of latency. These features include: Intel®Turbo Boost Technology,
  Enhanced Intel®SpeedStep, Processor C state and P state. Normally they
  should be disabled but, depending on the real-time application design and
  latency requirements, there might be some features that can be enabled if
  the impact on deterministic execution of the workload is small.

* **Hyper-Threading:**
  The logic cores that share resource with other logic cores can introduce
  latency so the recommendation is to disable this feature for realtime use
  cases.

* **Legacy USB Support/Port 60/64 Emulation:**
  These features involve some emulation in firmware and can introduce random
  latency. It is recommended that they are disabled.

* **SMI (System Management Interrupt):**
  SMI runs outside of the kernel code and can potentially cause
  latency. It is a pity there is no simple way to disable it. Some vendors may
  provide related switches in BIOS but most machines do not have this
  capability.

Operating System Configuration
------------------------------

* **CPU isolation:**
  To achieve deterministic latency, dedicated CPUs should be allocated for
  realtime application. This can be achieved by isolating cpus from kernel
  scheduler. Please refer to
  http://lxr.free-electrons.com/source/Documentation/kernel-parameters.txt#L1608
  for more information.

* **Memory allocation:**
  Memory shoud be reserved for realtime applications and usually hugepage
  should be used to reduce page fauts/TLB misses.

* **IRQ affinity:**
  All the non-realtime IRQs should be affinitized to non realtime CPUs to
  reduce the impact on realtime CPUs. Some OS distributions contain an
  irqbalance daemon which balances the IRQs among all the cores dynamically.
  It should be disabled as well.

* **Device assignment for VM:**
  If a device is used in a VM, then device passthrough is desirable. In this
  case,the IOMMU should be enabled.

* **Tickless:**
  Frequent clock ticks cause latency. CONFIG_NOHZ_FULL should be enabled in
  the linux kernel. With CONFIG_NOHZ_FULL, the physical CPU will trigger many
  fewer clock tick interrupts(currently, 1 tick per second). This can reduce
  latency because each host timer interrupt triggers a VM exit from guest to
  host which causes performance/latency impacts.

* **TSC:**
  Mark TSC clock source as reliable. A TSC clock source that seems to be
  unreliable causes the kernel to continuously enable the clock source
  watchdog to check if TSC frequency is still correct. On recent Intel
  platforms with Constant TSC/Invariant TSC/Synchronized TSC, the TSC is
  reliable so the watchdog is useless but cause latency.

* **Idle:**
  The poll option forces a polling idle loop that can slightly improve the
  performance of waking up an idle CPU.

* **RCU_NOCB:**
  RCU is a kernel synchronization mechanism. Refer to
  http://lxr.free-electrons.com/source/Documentation/RCU/whatisRCU.txt for more
  information. With RCU_NOCB, the impact from RCU to the VNF will be reduced.

* **Disable the RT throttling:**
  RT Throttling is a Linux kernel mechanism that
  occurs when a process or thread uses 100% of the core, leaving no resources
  for the Linux scheduler to execute the kernel/housekeeping tasks. RT
  Throttling increases the latency so should be disabled.

* **NUMA configuration:**
  To achieve the best latency. CPU/Memory and device allocated for realtime
  application/VM should be in the same NUMA node.

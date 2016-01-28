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

Some special CPU features like TSC-deadline timer, invariant TSC and Process posted
interrupts, etc, are helpful for latency reduction.

Below is the CPU information on the baseline test platform.
::
        processor       : 35
        vendor_id       : GenuineIntel
        cpu family      : 6
        model           : 63
        model name      : Intel(R) Xeon(R) CPU E5-2699 v3 @ 2.30GHz
        stepping        : 2
        microcode       : 0x2d
        cpu MHz         : 2294.795
        cache size      : 46080 KB
        physical id     : 1
        siblings        : 18
        core id         : 27
        cpu cores       : 18
        apicid          : 118
        initial apicid  : 118
        fpu             : yes
        fpu_exception   : yes
        cpuid level     : 15
        wp              : yes
        flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
                          mca cmov pat pse36 clflush dts acpi mmx fxsr sse
                          sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm
                          constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc
                          aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2
                          ssse3 fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt
                          tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm arat epb
                          pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase
                          tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm xsaveopt cqm_llc
                          cqm_occup_llcbugs
        bogomips        : 4595.54
        clflush size    : 64
        cache_alignment : 64
        address sizes   : 46 bits physical, 48 bits virtual
        power management:

CPU Topology
~~~~~~~~~~~~

NUMA topology is also important for latency reduction.

Below is the CPU topology on the baseline test platform.
::
        [nfv@otcnfv02 ~]$ lscpu
        Architecture:          x86_64
        CPU op-mode(s):        32-bit, 64-bit
        Byte Order:            Little Endian
        CPU(s):                36
        On-line CPU(s) list:   0-35
        Thread(s) per core:    1
        Core(s) per socket:    18
        Socket(s):             2
        NUMA node(s):          2
        Vendor ID:             GenuineIntel
        CPU family:            6
        Model:                 63
        Model name:            Intel(R) Xeon(R) CPU E5-2699 v3 @ 2.30GHz
        Stepping:              2
        CPU MHz:               2294.795
        BogoMIPS:              4595.54
        Virtualization:        VT-x
        L1d cache:             32K
        L1i cache:             32K
        L2 cache:              256K
        L3 cache:              46080K
        NUMA node0 CPU(s):     0-17
        NUMA node1 CPU(s):     18-35

BIOS Setup
~~~~~~~~~~

Careful BIOS setup is important in achieving real time latency. Different
platforms have different BIOS setups, below are the important BIOS settings on
the platform used to collect the baseline performance data.
::
        CPU Power and Performance <Performance>
        CPU C-State <Disabled>
        C1E Autopromote <Disabled>
        Processor C3 <Disabled>
        Processor C6 <Disabled>
        Select Memory RAS <Maximum Performance>
        NUMA Optimized <Enabled>
        Cluster-on-Die <Disabled>
        Patrol Scrub <Disabled>
        Demand Scrub <Disabled>
        Correctable Error <10>
        Intel(R) Hyper-Threading <Disabled>
        Active Processor Cores <All>
        Execute Disable Bit <Enabled>
        Intel(R) Virtualization Technology <Enabled>
        Intel(R) TXT <Disabled>
        Enhanced Error Containment Mode <Disabled>
        USB Controller <Enabled>
        USB 3.0 Controller <Auto>
        Legacy USB Support <Disabled>
        Port 60/64 Emulation <Disabled>

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
        isolcpus=11-15,31-35 nohz_full=11-15,31-35 rcu_nocbs=11-15,31-35 iommu=pt intel_iommu=on default_hugepagesz=1G hugepagesz=1G mce=off idle=poll intel_pstate=disable processor.max_cstate=1 pcie_asmp=off tsc=reliable

Below is guest kernel boot line example
::
 isolcpus=1 nohz_full=1 rcu_nocbs=1 mce=off idle=poll default_hugepagesz=1G hugepagesz=1G

Please refer to :doc:`tunning` for more explanation.

Run-time Environment Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~

Not only are special kernel parameters needed but a special run-time
environment is also required. Please refer to :doc:`tunning` for more
explanation.

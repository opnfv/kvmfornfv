Test Environment
================

The KVM4NFV testing, especially the latency, requires special test environment
setup. These setup include BIOS setup, kernel configuration, kernel parameter
and run time environment.

Hardware Platform Description
=============================

This section describes an example hardware platform environment, this that is
used to conduct the baseline performance data collection.

CPU Info::
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
        flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge\
        mca cmov pat pse36 clflush dts acpi mmx fxsr sse \
        sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm\
        constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc\
        aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2\
        ssse3 fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt\
        tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm arat epb\
        pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase\
        tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm xsaveopt cqm_llc\
        cqm_occup_llcbugs
        bogomips        : 4595.54
        clflush size    : 64
        cache_alignment : 64
        address sizes   : 46 bits physical, 48 bits virtual
        power management:

CPU Topology::
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
==========
Carefully BIOS setup is important to achieve real time latency. Different
platform has different BIOS setup, below is the important BIOS setting on the
platform collecting the baseline performance data.

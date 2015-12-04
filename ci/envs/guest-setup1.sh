#!/bin/bash
##############################################################################
## Copyright (c) 2015 Intel Corp.
##
## All rights reserved. This program and the accompanying materials
## are made available under the terms of the Apache License, Version 2.0
## which accompanies this distribution, and is available at
## http://www.apache.org/licenses/LICENSE-2.0
###############################################################################

set_irq_affinity () {
    echo 0 > /proc/irq/${1}/smp_affinity_list
}

# Disable watchdogs to reduce overhead
echo 0 > /proc/sys/kernel/watchdog
echo 0 > /proc/sys/kernel/nmi_watchdog

# Route device interrupts to non-RT CPU
set_irq_affinity 14
set_irq_affinity 15
for irq in `cat /proc/interrupts | grep virtio | cut -d ':' -f 1` ; do
    set_irq_affinity ${irq}
done

# Disable RT throttling
echo -1 > /proc/sys/kernel/sched_rt_period_us
echo -1 > /proc/sys/kernel/sched_rt_runtime_us

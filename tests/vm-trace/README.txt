vm-trace is a tool utilizing the ftrace infrastructure in Linux kernel to
measure VM preemption latencies.  For more info about ftrace, see
Documentation/trace/ftrace.txt.  See include/linux/ring_buffer.h and
include/linux/ftrace_event.h for data structures used by ftrace.

The tool enables 2 trace points in KVM driver:
kvm_exit defined in vmx_vcpu_run() (see arch/x86/kvm/vmx.c), and
kvm_entry defined in vcpu_enter_guest() (see arch/x86/kvm/x86.c).

It then spawns a thread to extract trace data from the kernel ftrace ring
buffer using the splice() system call.  Once the tracing duration has elapsed,
vm-trace calculates VM exit-entry latencies based on the timestamps of the
events.  (A future improvement could be to spawn another thread to process the
trace on the fly to improve vm-trace's performance.)

To take a trace, do the following:

1. Run qemu-kvm to start guest VM
2. Bind each qemu-kvm vCPU thread to an isolated pCPU
3. Start desired workload on the guest
4. Run vm-trace on the host:
   vm-trace -p cpu_to_trace -c cpu_to_collect_trace -s duration_in_seconds

cpu_to_trace is one of the pCPUs from step 2 above that you want to trace.
vm-trace does not support tracing multiple pCPUs.

cpu_to_collect_trace is the CPU used to read and save the trace data.
If the host system is NUMA, make sure to assign a CPU in the same NUMA node
as cpu_to_trace to cpu_to_collect_trace.

A binary file named trace.bin will be saved in the current working directory.
Be aware that, depending on the tracing duration and type of workload running
on the guest, the file can become quite large.

vm-trace requires root privileges.

Some statistics of the events will be displayed similar to the following:

  Number of VM events = 21608832
  Average VM Exit-Entry latency = 1us
  Maximum VM Exit-Entry latency = 5us
  Maximum cumulative latency within 1ms = 12us

trace.bin will be overwritten each time vm-trace is run in this mode,
so rename/copy the file if you want to keep it.

To process a previously collected trace file, run:
  vm-trace -f trace_file [-v]

If -v is specified, all events in the trace file will be displayed.
This is helpful for identifying cause of long latency.

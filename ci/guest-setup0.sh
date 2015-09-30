#!/bin/bash

source guest-config

config_grub () {
    key=$1
    val=$2

    if  grep '[" ]'${key} /etc/default/grub > /dev/null ; then
        sed -i  's/\([" ]\)'${key}'=[^ "]*/\1'${key}'='${val}'/' /etc/default/grub
    else
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 '${key}'='${val}'"/' /etc/default/grub
    fi
}

# Isolate CPUs from the general scheduler
config_grub 'isolcpus' ${guest_isolcpus}

# Stop timer ticks on isolated CPUs whenever possible
config_grub 'nohz_full' ${guest_isolcpus}

# Disable machine check
config_grub 'mce' 'off'

# Use polling idle loop to improve performance
config_grub 'idle' 'poll'

sed -i s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/ /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

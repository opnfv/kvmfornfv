$kvm_settings = hiera('fuel-plugin-kvm')
if $operatingsystem == 'Ubuntu' {
        if $kvm_settings['use_kvm'] {
                package { 'linux-headers-4.4.6-rt14nfv':
                        ensure => "1.0.OPNFV",
                        notify => Reboot['after_run'],
                } ->
                package { 'linux-image-4.4.6-rt14nfv':
                        ensure => "1.0.OPNFV",
                        notify => Reboot['after_run'],
                }
                reboot { 'after_run':
                    apply => finished,
                }
        } else {
        }
} elsif $operatingsystem == 'CentOS' {
}

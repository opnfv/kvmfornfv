$fuel_settings = parseyaml(file('/etc/astute.yaml'))
if $operatingsystem == 'Ubuntu' {
        if $fuel_settings['fuel-plugin-kvm']['use_kvm'] {
                package { 'linux-headers-4.4.6-rt14nfv':
                        ensure => "1.0.OPNFV",
                } ->
                package { 'linux-image-4.4.6-rt14nfv':
                        ensure => "1.0.OPNFV",
                } ->
                exec {'reboot':
                       command => "reboot",
                       path   => "/usr/bin:/usr/sbin:/bin:/sbin",
                }
        } else {
        }
} elsif $operatingsystem == 'CentOS' {
}

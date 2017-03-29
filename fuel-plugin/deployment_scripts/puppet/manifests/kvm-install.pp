$kvm_settings = hiera('fuel-plugin-kvm')

case $::operatingsystem {
  'Ubuntu': {
    $version         = '4.4.6-rt14nfv'
    $kernel_kit      = ["linux-headers-${version}", "linux-image-${version}"]
    $kernel_src      = "/usr/src/linux-headers-${version}"
    $kernel_src_link = "/lib/modules/${version}/build"

    shellvar { 'GRUB_DEFAULT':
      ensure => present,
      target => '/etc/default/grub',
      value  => "Advanced options for Ubuntu>Ubuntu, with Linux ${version}",
      quoted => 'double',
      notify => Exec['update_grub'],
    }
  }
  default: {
    fail("Unsupported operating system: ${::osfamily}/${::operatingsystem}")
  }

}

if $kvm_settings['use_kvm'] {
  $ensure_pkg  = '1.0.OPNFV'
  $ensure_link = 'link'
} else {
  $ensure_pkg  = 'purged'
  $ensure_link = 'absent'
}

exec { 'update_grub':
  command     => '/usr/sbin/update-grub',
  refreshonly => true,
}

package { $kernel_kit:
  ensure => $ensure_pkg,
  before => File[$kernel_src_link],
}

file { $kernel_src_link:
  ensure => $ensure_link,
  target => $kernel_src,
}

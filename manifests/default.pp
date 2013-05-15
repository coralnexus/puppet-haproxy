
class haproxy::default {

  case $::operatingsystem {
    debian, ubuntu: {
      $common_package_names    = ['haproxy']
      $service_name            = 'haproxy'

      $default_config_file     = '/etc/default/haproxy'
      $config_file             = '/etc/haproxy/haproxy.cfg'

      $chroot_dir              = '/usr/share/haproxy'
    }
    default: {
      fail("The haproxy module is not currently supported on ${::operatingsystem}")
    }
  }
}


class haproxy::params inherits haproxy::default {

  $base_name = 'haproxy'

  #---

  $build_package_names  = module_array('build_package_names')
  $common_package_names = module_array('common_package_names')
  $extra_package_names  = module_array('extra_package_names')
  $package_ensure       = module_param('package_ensure', 'present')

  #---

  $config_file     = module_param('config_file')
  $config_template = module_param('config_template', 'haproxy')

  $chroot_dir  = module_param('chroot_dir')

  # For configuration options: see http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
  $config = module_hash('config', {
    'global' => {
      'daemon' => '',
      'chroot' => $chroot_dir,
      'user'   => 'root',
      'group'  => 'haproxy',
      'node'   => $::hostname,
      'log'    => {
        '/dev/log' => {
          'local0' => {
            'info'   => '',
            'notice' => ''
          }
        }
      },
      'maxconn' => 5000,
      'debug'   => undef,
      'quiet'   => undef
    },
    'defaults' => {
      'log'     => 'global',
      'mode'    => 'http',
      'retries' => 3,
      'maxconn' => 1000,
      'timeout' => {
        'connect' => '5000ms',
        'client'  => '50000ms',
        'server'  => '50000ms'
      },
      'option' => {
        'tcplog'      => '',
        'dontlognull' => '',
        'redispatch'  => ''
      }
    }
  })

  $user  = interpolate($config['global']['user'], $config['global'])
  $group = interpolate($config['global']['group'], $config['global'])

  #---

  $env_template        = module_param('env_template', 'environment')
  $default_config_file = module_param('default_config_file')
  $default_config      = module_hash('default_config', {
    'ENABLED'   => ensure(haproxy_firewall($config), '1', '0'),
    'EXTRAOPTS' => '-de -m 16'
  })

  #---

  $service_name   = module_param('service_name')
  $service_ensure = module_param('service_ensure', 'running')
}

# Class: haproxy
#
#   This module manages the HAProxy server.
#
#   Adrian Webb <adrian.webb@coralnexus.com>
#   2013-05-07
#
#   Tested platforms:
#    - Ubuntu 12.04
#
# Parameters: (see <example/params.json> for Hiera configurations)
#
# Actions:
#
#  Installs, configures, and manages the HAProxy server.
#
# Requires:
#
# Sample Usage:
#
#   include haproxy
#
class haproxy inherits haproxy::params {

  $base_name = $haproxy::params::base_name

  #-----------------------------------------------------------------------------
  # Installation

  corl::package { $base_name:
    resources => {
      build_packages  => {
        name => $haproxy::params::build_package_names
      },
      common_packages => {
        name    => $haproxy::params::common_package_names,
        require => 'build_packages'
      },
      extra_packages  => {
        name    => $haproxy::params::extra_package_names,
        require => 'common_packages'
      }
    },
    defaults  => {
      ensure => $haproxy::params::package_ensure
    }
  }

  #-----------------------------------------------------------------------------
  # Configuration

  $config = $haproxy::params::config

  #---

  corl::file { $base_name:
    resources => {
      chroot_dir => {
        path   => $haproxy::params::chroot_dir,
        ensure => directory,
        owner  => $haproxy::params::user,
        group  => $haproxy::params::group,
      },
      default_config => {
        path    => $haproxy::params::default_config_file,
        content => render($haproxy::params::env_template, $haproxy::params::default_config)
      },
      config_dir => {
        path   => $haproxy::params::config_dir,
        ensure => directory
      },
      config => {
        path    => $haproxy::params::config_file,
        content => render($haproxy::params::config_template, $config),
        require => 'config_dir'
      }
    },
    defaults => {
      notify => Service["${base_name}_service"]
    }
  }

  #---

  corl::firewall { $base_name:
    resources => haproxy_firewall($config, 'INPUT Allow HAProxy connections'),
    defaults  => {
      action => 'accept',
      chain  => 'INPUT',
      state  => 'NEW',
      proto  => 'tcp'
    }
  }

  #-----------------------------------------------------------------------------
  # Actions

  corl::exec { $base_name: }

  #-----------------------------------------------------------------------------
  # Services

  corl::service { $base_name:
    resources => {
      service => {
        name   => $haproxy::params::service_name,
        ensure => $haproxy::params::service_ensure,
        enable => true
      }
    },
    require => [ Corl::Package[$base_name], Corl::File[$base_name] ]
  }

  #---

  corl::cron { $base_name:
    require => Corl::Service[$base_name]
  }
}

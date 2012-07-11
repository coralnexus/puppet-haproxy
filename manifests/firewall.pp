
class haproxy::firewall (

  $proxies = $haproxy::params::proxies,

) inherits haproxy::params {

  #-----------------------------------------------------------------------------

  $proxy_ports = proxy_ports($proxies)

  if $proxy_ports {
    haproxy::rule { $proxy_ports: }
  }
}

#-------------------------------------------------------------------------------

define haproxy::rule($port) {

  if $port {
    firewall { "200 INPUT Allow HAProxy connections: $port":
      action => accept,
      chain  => 'INPUT',
      state  => 'NEW',
      proto  => 'tcp',
      dport  => $port,
    }
  }
}

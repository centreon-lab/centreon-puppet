#
# Centreon Web deploy
#

class centreon::web (
  $php_timezone = 'Europe/Paris',
) inherits ::centreon::common {

  include stdlib

  $centreon_web_packages = [
    'centreon-base-config-centreon-engine',
    'centreon'
  ]

  package { $centreon_web_packages:
    ensure  => latest,
    require => Exec['Centreon import GPG repository key']
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
    require => Package[$centreon_web_packages]
  }

  file { '/etc/php.d/php-timezone.ini':
    ensure  => present,
    content => "date.timezone = ${php_timezone}",
    require => Package[$centreon_web_packages]
  }

  file { '/var/spool/centreon':
    ensure => 'directory',
    owner  => 'centreon',
    group  => 'centreon',
    mode   => '0775'
  }

  exec { 'Generate SSH keys':
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => 'ssh-keygen -t rsa -f /var/spool/centreon/.ssh/id_rsa -q -N ""',
    user    => 'centreon',
    creates => '/var/spool/centreon/.ssh/id_rsa',
    require => [
      File['/var/spool/centreon'],
      Package[$centreon_web_packages]
    ]
  }

  file { '/etc/centreon/centreon.conf.php':
    content => template('centreon/centreon.conf.php.erb'),
    owner   => 'centreon',
    group   => 'centreon',
    mode    => '0644',
    require => Package[$centreon_web_packages],
    notify  => Service['httpd']
  }

  service { 'centcore':
    ensure  => running,
    enable  => true,
    require => Package[$centreon_web_packages]
  }

  file { '/etc/centreon/conf.pm':
    content => template('centreon/conf.pm.erb'),
    owner   => 'centreon',
    group   => 'centreon',
    mode    => '0644',
    require => Package[$centreon_web_packages],
    notify  => Service['centcore']
  }

  include centreon::web_config

}

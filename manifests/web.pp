#
# Centreon Web deploy
#

class centreon::web (
  String $mysql_centreon_hostname    = 'localhost',
  String $mysql_centstorage_hostname = 'localhost',
  String $mysql_port                 = '3306',
  String $mysql_centreon_username    = 'centreon',
  String $mysql_centreon_db          = 'centreon',
  String $mysql_centstorage_db       = 'centreon_storage',
  String $mysql_root_password        = 'changeme',
  String $mysql_centreon_password    = 'changeme',
  String $centreon_admin_password    = 'changeme',
  String $php_timezone               = 'Europe/Paris',
  Array  $plugin_pack                = ['base-generic', 'Linux SNMP']
) inherits ::centreon::common {

  include stdlib

  package { 'centos-release-scl':
    ensure  => latest
  }

  $centreon_web_packages = [
    'centreon-base-config-centreon-engine',
    'centreon'
  ]

  package { $centreon_web_packages:
    ensure  => latest,
    require => [
      Package['centreon-release'],
      Package['centos-release-scl']
    ]
  }

  file { '/etc/opt/rh/rh-php71/php.d/php-timezone.ini':
    ensure  => present,
    content => "date.timezone = ${php_timezone}",
    require => Package[$centreon_web_packages],
    notify  => Service['httpd']
  }

  service { 'rh-php71-php-fpm':
    ensure  => running,
    enable  => true,
    require => Package[$centreon_web_packages]
  }

  service { 'httpd':
    ensure  => running,
    enable  => true,
    require => Package[$centreon_web_packages]
  }

  # Init deploy initial configuration
  file { '/tmp/missing_tables.sql':
    mode   => '0644',
    source => 'puppet:///modules/centreon/missing_tables.sql'
  }

  file { '/tmp/deploy_initial_config.sh':
    content => template('centreon/deploy_initial_config.sh.erb'),
    mode    => '0644',
    require => Package[$centreon_web_packages]
  }

  file { '/tmp/do_replace.py':
    content => template('centreon/do_replace.py.erb'),
    mode    => '0755',
    require => Package[$centreon_web_packages]
  }

  exec { 'set-mysql-password':
    unless  => "mysqladmin -uroot -p${mysql_root_password} status",
    path    => ['/bin', '/usr/bin'],
    command => "mysqladmin -uroot password ${mysql_root_password}",
    require => Service['mysqld'],
  }

  exec { 'Run deploy initial configuration':
    command   => '/usr/bin/sh /tmp/deploy_initial_config.sh',
    require   => [
      File['/tmp/deploy_initial_config.sh'],
      File['/tmp/do_replace.py']
    ]
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
    require => [
      Exec['Run deploy initial configuration'],
      Package[$centreon_web_packages]
    ]
  }

  file { '/etc/centreon/conf.pm':
    content => template('centreon/conf.pm.erb'),
    owner   => 'centreon',
    group   => 'centreon',
    mode    => '0644',
    require => Package[$centreon_web_packages],
    notify  => Service['centcore']
  }

  class { 'firewalld': }
  firewalld_port { 'Open port 80 to Centreon Web':
    ensure   => present,
    zone     => 'public',
    port     => 80,
    protocol => 'tcp',
  }

  file { '/tmp/install_modules.php':
    mode    => '0644',
    source  => 'puppet:///modules/centreon/install_modules.php',
    require => [
      Package[$centreon_web_packages],
      Service['rh-php71-php-fpm']
    ]
  }

  exec { 'Install Plugin Manager extension':
    command => '/opt/rh/rh-php71/root/bin/php /tmp/install_modules.php',
    require => [
      Exec['Run deploy initial configuration'],
      File['/tmp/install_modules.php']
    ]
  }

  package { ['python-requests', 'python-lxml']:
    ensure  => latest
  }

  file { '/tmp/do_install_basic_plugins.py':
    content => template('centreon/do_install_basic_plugins.py.erb'),
    mode    => '0644',
    require => [
      Package[$centreon_web_packages],
      Package[['python-requests', 'python-lxml']]
    ]
  }

  exec { 'Install Plugins':
    command => '/usr/bin/python /tmp/do_install_basic_plugins.py',
    require => [
      Exec['Run deploy initial configuration'],
      File['/tmp/do_install_basic_plugins.py']
    ]
  }

}

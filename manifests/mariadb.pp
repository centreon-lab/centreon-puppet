#
# Centreon Web MariaDB server
#

class centreon::mariadb inherits ::centreon::common {

  package { 'MariaDB-server':
    ensure  => latest,
    require => Package['centreon-release']
  }

  service { 'mysqld':
    ensure  => running,
    enable  => true,
    require => Package['MariaDB-server']
  }

  exec { 'set-mysql-password':
    unless  => "mysqladmin -uroot -p${mysql_root_password} status",
    path    => ['/bin', '/usr/bin'],
    command => "mysqladmin -uroot password ${mysql_root_password}",
    require => Service['mysqld'],
  }

  if $::operatingsystemmajrelease == 7 {
    file { '/etc/systemd/system/mariadb.service.d/limits.conf':
      ensure  => present,
      content => "[Service]
        LimitNOFILE=32000",
      notify  => Exec['reload systemctl'],
      require => Package['MariaDB-server']
    }
    exec { 'reload systemctl':
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => 'systemctl daemon-reload'
    }
  }


}

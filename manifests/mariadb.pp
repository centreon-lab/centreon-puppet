#
# Centreon Web MariaDB server
#

class centreon::mariadb inherits ::centreon::common {

  $mariadb_packages = [
    'MariaDB-server'
  ]

  package { $mariadb_packages:
    ensure  => latest,
    require => Exec['Centreon import GPG repository key']
  }

  service { 'mysql':
    ensure  => running,
    enable  => true,
    require => Package[$mariadb_packages]
  }

  if $::operatingsystemmajrelease == 7 {
    file { '/etc/systemd/system/mariadb.service.d/limits.conf':
      ensure  => present,
      content => "[Service]
        LimitNOFILE=32000",
      notify  => Exec['reload systemctl'],
      require => Package[$mariadb_packages]
    }
    exec { 'reload systemctl':
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => 'systemctl daemon-reload'
    }
  }

}

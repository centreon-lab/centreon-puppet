#
# Centreon Web MariaDB server
#

class centreon::mariadb inherits ::centreon::common {

  class {'::mysql::server':
    package_name     => 'MariaDB-server',
    package_ensure   => '10.1.36-1.el7.centos',
    service_name     => 'mysql',
    root_password    => 'AVeryStrongPasswordUShouldEncrypt!',
    override_options => {
      mysqld => {
        'log-error' => '/var/log/mysql/mariadb.log',
        'pid-file'  => '/var/run/mysqld/mysqld.pid',
      },
      mysqld_safe => {
        'log-error' => '/var/log/mysql/mariadb.log',
      },
    }
  }

  if $::operatingsystemmajrelease == 7 {
    file { '/etc/systemd/system/mariadb.service.d/limits.conf':
      ensure  => present,
      content => "[Service]
        LimitNOFILE=32000",
      notify  => Exec['reload systemctl'],
      require => Class['::mysql::server']
    }
    exec { 'reload systemctl':
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
      command => 'systemctl daemon-reload'
    }
  }


}

#
# Centreon web replaces
#
class centreon::web_replaces (
  $mysql_centreon_hostname = 'localhost',
  $mysql_port = '3306',
  $mysql_centreon_username = 'centreon',
  $mysql_centreon_db = 'centreon',
  $mysql_centstorage_db = 'centreon_storage'
) {

  file { '/tmp/sed_command.sh':
    content => template('centreon/sed_command.sh.erb'),
    mode    => '0755',
    require => Package[$centreon_web_packages]
  }

  $files = [
    '/usr/share/centreon/www/install/createTablesCentstorage.sql',
    '/usr/share/centreon/www/install/insertBaseConf.sql',
    '/usr/share/centreon/www/install/var/baseconf/centreon-broker.sql',
    '/usr/share/centreon/www/install/var/baseconf/centreon-engine.sql'
  ]

  $files.each |String $file| {
    file { $file:
      ensure  => present,
      require => [
        File['/usr/share/centreon/install'],
        Package[$centreon_web_packages]
      ]
    }
    create_resources(exec,
      { 
        "Replaces in ${file}" => {
          command => "/bin/sh /tmp/sed_command.sh ${file}",
          require => [File['/tmp/sed_command.sh'], File[$file]]
        }
      }
    )
  }

  centreon::dbcreate { $mysql_centreon_db:
      user     => $mysql_centreon_username,
      password => $mysql_centreon_password,
      sql      => '/usr/share/centreon/www/install/createTables.sql'
  }

  centreon::dbcreate { $mysql_centstorage_db:
      user     => $mysql_centreon_username,
      password => $mysql_centreon_password,
      sql      => '/usr/share/centreon/www/install/createTablesCentstorage.sql'
  }

}

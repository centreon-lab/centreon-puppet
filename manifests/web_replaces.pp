#
# Centreon web replaces
#
class centreon::web_replaces inherits ::centreon::params {

  file { '/tmp/do_replace.py':
    content => template('centreon/do_replace.py.erb'),
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
          command => "/bin/python /tmp/do_replace.py ${file}",
          require => [File['/tmp/do_replace.py'], File[$file]]
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

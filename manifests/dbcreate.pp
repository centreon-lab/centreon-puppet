
class centreon::dbcreate inherits ::centreon::mariadb (
  $centreon_admin_password = 'changeme',
  $mysql_root_password = 'changeme',
  $mysql_centreon_password = 'changeme',
  $mysql_centreon_hostname = 'localhost',
  $mysql_port = '3306',
  $mysql_centreon_username = 'centreon',
  $mysql_centreon_db = 'centreon',
  $mysql_centstorage_db = 'centreon_storage'
) {

  define centreon::dbcreate( $user, $password, $sql ) {
    $ml_exec = @(EOT)
      /usr/bin/mysql -uroot -p$mysql_password -e \
      \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"
      /usr/bin/mysql -u$user -p$password ${name} <$sql
    | EOT
    exec { "create-${name}-db":
      unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
      command => $ml_exec,
      require => Service['mysqld'],
    }
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

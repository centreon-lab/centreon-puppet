
define centreon::dbcreate( $user, $password, $sql ) {
  exec { "create-${name}-db":
    unless  => "/bin/mysql -u${user} -p${password} ${name}",
    command => "/bin/mysql -uroot -p'$mysql_root_password' -e \"CREATE DATABASE IF NOT EXISTS ${name}; GRANT ALL ON ${name}.* TO ${user}@localhost identified by '${password}';\" && /bin/mysql -u${user} -p'${password}' ${name} < ${sql}",
    require => [
      Package[$centreon_web_packages],
      Service['mysqld'],
      Exec['Run deploy initial configuration']
    ]
  }
}

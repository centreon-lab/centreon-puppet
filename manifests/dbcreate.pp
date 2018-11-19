
define centreon::dbcreate( $user, $password, $sql ) {
  exec { "create-${name}-db":
    unless  => "/bin/mysql -u${user} -p${password} ${name}",
    command => "/bin/mysql -uroot -p$mysql_root_password -e \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '${password}';\" && /bin/mysql -u${user} -p${password} ${name} < ${sql}",
    require => Service['mysqld'],
  }
}

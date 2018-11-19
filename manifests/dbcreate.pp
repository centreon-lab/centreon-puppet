
define centreon::dbcreate( $user, $password, $sql ) {
  $ml_exec = @(EOT)
    /usr/bin/mysql -uroot -p$mysql_password -e \
    \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"
    /usr/bin/mysql -u${user} -p${password} ${name} <$sql
  | EOT
  exec { "create-${name}-db":
    unless  => "/usr/bin/mysql -u${user} -p${password} ${name}",
    command => $ml_exec,
    require => Service['mysqld'],
  }
}

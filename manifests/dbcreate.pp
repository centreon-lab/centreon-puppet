
define centreon::dbcreate( $mysql_root_password = 'changeme', $user, $password, $sql ) {
  $ml_exec = @(EOT)
    /bin/mysql -uroot -p$mysql_root_password -e \
    \"create database ${name}; grant all on ${name}.* to ${user}@localhost identified by '$password';\"
    /bin/mysql -u${user} -p${password} ${name} <$sql
  | EOT
  exec { "create-${name}-db":
    unless  => "/bin/mysql -u${user} -p${password} ${name}",
    command => $ml_exec,
    require => Service['mysqld'],
  }
}
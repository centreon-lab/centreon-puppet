#
# Centreon web initial configuration
#
class centreon::web_config (
  $centreon_admin_password = 'changeme',
  $mysql_centreon_password = 'changeme'
  ){

  # Create install directory
  file { '/usr/share/centreon/install':
    ensure  => 'directory',
  }

  file { '/usr/share/centreon/install/missing_tables.sql':
    mode   => '0644',
    source => 'puppet:///modules/centreon/missing_tables.sql'
  }

  file { '/usr/share/centreon/www/install/insertBaseConf.sql':
    ensure  => present,
  }->
  file_line { 'Set the admin password in Centreon Web':
    path  => '/usr/share/centreon/www/install/insertBaseConf.sql',
    match => '@ADMIN_PASSWORD@',
    line  => $centreon_admin_password,
  }->
  file_line { 'Set Mysql centreon password':
    path  => '/usr/share/centreon/www/install/insertBaseConf.sql',
    match => '$dbpasswd',
    line  => $mysql_centreon_password,
  }

}

#
# Centreon web replaces
#
class centreon::web_replaces (
  $centreon_admin_password = 'changeme',
  $mysql_root_password = 'changeme',
  $mysql_centreon_password = 'changeme',
  $mysql_centreon_hostname = 'localhost',
  $mysql_port = '3306',
  $mysql_centreon_username = 'centreon',
  $mysql_centreon_db = 'centreon',
  $mysql_centstorage_db = 'centreon_storage'
) {

  class { '::mysql::server':
    root_password           => $mysql_root_password,
    remove_default_accounts => true
  }

  $items = [
    {
      match => '@CENTREON_DIR@',
      line => '/usr/share/centreon/'
    },
    {
      match => '@CENTREON_ETC@',
      line => '/etc/centreon/'
    },
    {
      match => '@CENTREON_DIR_WWW@',
      line => '/usr/share/centreon/www/'
    },
    {
      match => '@CENTREON_DIR_RRD@',
      line => '/var/lib/centreon'
    },
    {
      match => '@CENTREON_LOG@',
      line => '/var/log/centreon'
    },
    {
      match => '@CENTREON_VARLIB@',
      line => '/var/lib/centreon'
    },
    {
      match => '@CENTREON_GROUP@',
      line => 'centreon'
    },
    {
      match => '@CENTREON_USER@',
      line => 'centreon'
    },
    { match => '@RRDTOOL_DIR@', line => '/usr/bin/rrdtool' },
    { match => '@APACHE_USER@', line => 'apache' },
    { match => '@APACHE_GROUP@', line => 'apache' },
    { match => '@MAILER@', line => '/bin/mail' },
    {
      match => '@MONITORINGENGINE_USER@',
      line => 'centreon-engine'
    },
    {
      match => '@MONITORINGENGINE_GROUP@',
      line => 'centreon-engine'
    },
    {
      match => '@MONITORINGENGINE_ETC@',
      line => '/etc/centreon-engine'
    },
    {
      match => '@MONITORING_INIT_SCRIPT@',
      line => 'centengine'
    },
    {
      match => '@MONITORING_BINARY@',
      line => '/usr/sbin/centengine'
    },
    {
      match => '@MONITORING_VAR_LOG@',
      line => '/var/log/centreon-engine'
    },
    {
      match => '@PLUGIN_DIR@',
      line => '/usr/lib/nagios/plugin'
    },
    {
      match => '@NAGIOS_PLUGIN@',
      line => '/usr/lib/nagios/plugin'
    },
    {
      match => '@CENTREON_ENGINE_CONNECTORS@',
      line => '/usr/lib64/centreon-connector'
    },
    {
      match => '@CENTREON_ENGINE_LIB@',
      line => '/usr/lib64/centreon-engine'
    },
    {
      match => '@CENTREONBROKER_CBMOD@',
      line => '/usr/lib64/nagios/cbmod.so'
    },
    {
      match => '@CENTREON_PLUGINS@',
      line => '/usr/lib/centreon/plugin'
    },
    {
      match => '@CENTREONBROKER_CBMOD@',
      line => '/usr/lib/nagios/cbmod.so'
    },
    {
      match => '@MONITORINGENGINE_PLUGIN@',
      line => '/usr/lib/nagios/plugin'
    },
    {
      match => '@MONITORING_VAR_LIB@',
      line => '/var/lib/centreon-engine'
    },
    {
      match => '@DB_HOST@',
      line => $mysql_centreon_hostname
    },
    { match => '@DB_PORT@', line => $mysql_port },
    { match => '@DB_USER@', line => $mysql_centreon_username },
    { match => '@UTILS_DB@', line => 'centreon_status' },
    {
      match => '@NDOMOD_BINARY@',
      line => '/usr/lib64/nagios/ndomod.o'
    },
    {
      match => '@CENTREON_ENGINE_STATS_BINARY@',
      line => '/usr/sbin/centenginestats'
    },
    { match => '@NAGIOS_BINARY@', line => '/usr/sbin/nagios' },
    {
      match => '@NAGIOSTATS_BINARY@',
      line => '/usr/bin/nagiostat'
    },
    {
      match => '@NAGIOS_INIT_SCRIPT@',
      line => '/etc/init.d/nagios'
    },
    { match => '@STORAGE_DB@', line => 'centreon_storage' },
    {
      match => '@CENTREON_ENGINE_LIB@',
      line => '/usr/lib64/centreon-engine'
    },
    {
      match => '@CENTREONBROKER_LIB@',
      line => '/usr/share/centreon/lib/centreon-broker'
    },
    { match => '@BROKER_USER@', line => 'centreon-broker' },
    { match => '@BROKER_GROUP@', line => 'centreon-broker' },
    {
      match => '@CENTREONBROKER_ETC@',
      line => '/etc/centreon-broker'
    },
    { match => '@BROKER_INIT_SCRIPT@', line => 'cbd' },
    {
      match => '@CENTREONBROKER_LOG@',
      line => '/var/log/centreon-broker'
    },
    {
      match => '@CENTREONBROKER_VARLIB@',
      line => '/var/lib/centreon-broker'
    },
    { 
      match => '@ADMIN_PASSWORD@',
      line => $centreon_admin_password
    },
    {
      match => '$dbpasswd',
      line => $mysql_centreon_password
    }
  ]

  $files = [
    '/usr/share/centreon/www/install/insertBaseConf.sql',
    '/usr/share/centreon/www/install/var/baseconf/centreon-broker.sql',
    '/usr/share/centreon/www/install/var/baseconf/centreon-engine.sql'
  ]

  $files.each |String $file| {

    file { $file:
      ensure  => present,
    }
    $file_ = $file
    $items.each |Hash $item| {
      $timestamp = generate('/bin/date', '+%H%M%S%N')
      $res = { "Replace ${timestamp} ${file_}" => $item }
      create_resources(file_line, $res,
        { path => $file_, multiple => true, require => File[$file_] }
      )
    }
  }

  class { '::mysql::db':
    db       => $mysql_centreon_db,
    user     => $mysql_centreon_username,
    password => $mysql_centreon_password,
    host     => 'localhost',
    grant    => ['ALL PRIVILEGES'],
    sql      => '/usr/share/centreon/www/install/createTables.sql'
  }

  class { '::mysql::db':
    db       => $mysql_centstorage_db,
    user     => $mysql_centreon_username,
    password => $mysql_centreon_password,
    host     => 'localhost',
    grant    => ['ALL PRIVILEGES'],
    sql      => '/usr/share/centreon/www/install/createTablesCentstorage.sql'
  }

}

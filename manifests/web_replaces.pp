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

  $exec_sed = @(EOT /)
  /bin/sed -i \
  -e 's/@CENTREON_DIR@/\/usr\/share\/centreon\//g' \
  -e 's/@CENTREON_ETC@/\/etc\/centreon\//g' \
  -e 's/@CENTREON_DIR_WWW@/\/usr\/share\/centreon\/www\//g' \
  -e 's/@CENTREON_DIR_RRD@/\/var\/lib\/centreon/g' \
  -e 's/@CENTREON_LOG@/\/var\/log\/centreon/g' \
  -e 's/@CENTREON_VARLIB@/\/var\/lib\/centreon/g' \
  -e 's/@CENTREON_GROUP@/centreon/g' \
  -e 's/@CENTREON_USER@/centreon/g' \
  -e 's/@RRDTOOL_DIR@/\/usr\/bin\/rrdtool/g' \
  -e 's/@APACHE_USER@/apache/g' \
  -e 's/@APACHE_GROUP@/apache/g' \
  -e 's/@MAILER@/\/bin\/mail/g' \
  -e 's/@MONITORINGENGINE_USER@/centreon-engine/g' \
  -e 's/@MONITORINGENGINE_GROUP@/centreon-engine/g' \
  -e 's/@MONITORINGENGINE_ETC@/\/etc\/centreon-engine/g' \
  -e 's/@MONITORING_INIT_SCRIPT@/centengine/g' \
  -e 's/@MONITORING_BINARY@/\/usr\/sbin\/centengine/g' \
  -e 's/@MONITORING_VAR_LOG@/\/var\/log/centreon-engine/g' \
  -e 's/@PLUGIN_DIR@/\/usr\/lib\/nagios\/plugin/g' \
  -e 's/@NAGIOS_PLUGIN@/\/usr\/lib\/nagios\/plugin/g' \
  -e 's/@CENTREON_ENGINE_CONNECTORS@/\/usr\/lib64\/centreon-connector/g' \
  -e 's/@CENTREON_ENGINE_LIB@/\/usr\/lib64\/centreon-engine/g' \
  -e 's/@CENTREONBROKER_CBMOD@/\/usr\/lib64\/nagios\/cbmod.so/g' \
  -e 's/@CENTREON_PLUGINS@/\/usr\/lib\/centreon\/plugin/g' \
  -e 's/@CENTREONBROKER_CBMOD@/\/usr\/lib\/nagios\/cbmod.so/g' \
  -e 's/@MONITORINGENGINE_PLUGIN@/\/usr\/lib\/nagios\/plugin/g' \
  -e 's/@MONITORING_VAR_LIB@/\/var\/lib\/centreon-engine/g' \
  -e 's/@DB_HOST@/${mysql_centreon_hostname}/g' \
  -e 's/@DB_PORT@/$mysql_port/g' \
  -e 's/@DB_USER@/$mysql_centreon_username/g' \
  -e 's/@UTILS_DB@/centreon_status/g' \
  -e 's/@NDOMOD_BINARY@/\/usr\/lib64\/nagios\/ndomod.o/g' \
  -e 's/@CENTREON_ENGINE_STATS_BINARY@/\/usr\/sbin\/centenginestats/g' \
  -e 's/@NAGIOS_BINARY@/\/usr\/sbin\/nagios/g' \
  -e 's/@NAGIOSTATS_BINARY@/\/usr\/bin\/nagiostat/g' \
  -e 's/@NAGIOS_INIT_SCRIPT@/\/etc\/init.d\/nagios/g' \
  -e 's/@STORAGE_DB@/centreon_storage/g' \
  -e 's/@CENTREON_ENGINE_LIB@/\/usr\/lib64\/centreon-engine/g' \
  -e 's/@CENTREONBROKER_LIB@/\/usr\/share\/centreon\/lib\/centreon-broker/g' \
  -e 's/@BROKER_USER@/centreon-broker/g' \
  -e 's/@BROKER_GROUP@/centreon-broker/g' \
  -e 's/@CENTREONBROKER_ETC@/\/etc\/centreon-broker/g' \
  -e 's/@BROKER_INIT_SCRIPT@/cbd/g' \
  -e 's/@CENTREONBROKER_LOG@/\/var\/log\/centreon-broker/g' \
  -e 's/@CENTREONBROKER_VARLIB@/\/var\/lib\/centreon-broker/g' \
  -e 's/@ADMIN_PASSWORD@/${centreon_admin_password}/g' \
  -e 's/\$dbpasswd/${mysql_centreon_password}/g' \
  -e 's/CREATE TABLE/CREATE TABLE IF NOT EXISTS/g'
  | EOT

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
          command => "${exec_sed} ${file}",
          require => File[$file]
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

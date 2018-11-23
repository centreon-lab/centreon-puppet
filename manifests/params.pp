#
# Centreon Params
#
class centreon::params {
  $mysql_centreon_hostname    = 'localhost'
  $mysql_centstorage_hostname = 'localhost'
  $mysql_port                 = '3306'
  $mysql_centreon_username    = 'centreon'
  $mysql_centreon_db          = 'centreon'
  $mysql_centstorage_db       = 'centreon_storage'
  $mysql_root_password        = 'changeme'
  $mysql_centreon_password    = 'changeme'
  $php_timezone               = 'Europe/Paris'
}

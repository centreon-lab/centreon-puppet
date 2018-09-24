#
# Centreon web initial configuration
#
class centreon::web_config {

  # Create install directory
  file { '/usr/share/centreon/install':
    ensure  => 'directory',
  }

  file { '/usr/share/centreon/install/missing_tables.sql':
    mode   => '0644',
    source => 'puppet:///modules/centreon/missing_tables.sql'
  }

  include centreon::web_replaces

}

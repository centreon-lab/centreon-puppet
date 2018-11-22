#
# Centreon web initial configuration
#
class centreon::web_config {

  if ($::centreon_install_dir == 'false') { 
    # Create install directory
    file { '/usr/share/centreon/install':
      ensure  => 'directory',
      require => Package[$centreon_web_packages]
    }

    file { '/usr/share/centreon/install/missing_tables.sql':
      mode   => '0644',
      source => 'puppet:///modules/centreon/missing_tables.sql',
      require => File['/usr/share/centreon/install']
    }

    include centreon::web_replaces

    # remove install dir
    exec { 'Remove install directory':
      command => '/bin/rm -rf /usr/share/centreon/install && /bin/rm -rf /usr/share/centreon/www/install'
    }
  }
}

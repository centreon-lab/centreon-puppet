#
# Centreon Configuration
#

class centreon::config inherits ::centreon::common {

  package { 'epel-release':
    ensure  => latest
  }

  $wrapper_packages = [
    'python34-requests',
    'python34-PyYAML'
  ]

  package { $wrapper_packages:
    ensure  => latest,
    require => Package['epel-release']
  }

  # Create wrapper file
  file { '/tmp/wrapper.py':
    content => template('centreon/wrapper.py.erb'),
    mode    => '0755',
    require => Package[$wrapper_packages],
  }

  # Create file config
  file { '/tmp/config.yml':
    content => template('centreon/wrapper-config.yml.erb'),
    mode    => '0644',
    require => File['/tmp/wrapper.py']
  }

  exec { 'Apply configuration using wrapper':
    command => '/usr/bin/python3 /tmp/wrapper.py',
    require => [
      File['/tmp/wrapper.py'],
      File['/tmp/config.yml'],
      Package[$wrapper_packages]
    ]
  }

}

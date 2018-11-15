#
# Centreon Puppet Common tasks
#

class centreon::common {

  if $::operatingsystem != 'CentOS' {
    # Not compatible with non CentOS
    fail('Not compatible with non CentOS operating system')

  } elsif ! $::operatingsystemmajrelease in [7] {
    # Not compatible with this version
    fail('You must use a Centos 7 version')
  }

  # Disable selinux
  class { '::selinux':
    mode => 'disabled',
  }

  class remoterpm ( $src ) {
    package { 'package':
      provider  => 'rpm',
      ensure    => installed,
      source    => "${remoterpm::src}"
    }
  }

  class { 'remoterpm':
    src => 'http://yum.centreon.com/standard/18.10/el7/stable/noarch/RPMS/centreon-release-18.10-2.el7.centos.noarch.rpm'',
  }

}

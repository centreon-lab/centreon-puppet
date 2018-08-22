#
# Centreon Puppet Common tasks
#

class centreon::common {

  if $::operatingsystem != 'CentOS' {
    # Not compatible with non CentOS
    ...

  } elsif ! $::operatingsystemmajrelease in [6,7] {
    # Not compatible with this version

  }

  # Add centreon repository
  file { '/etc/yum.repos.d/centreon-stable.repo':
    ensure => present,
    source => "http://yum.centreon.com/standard/3.4/el${::operatingsystemmajrelease}/stable/centreon-stable.repo",
  }

  # You’ll need to make sure /etc/pki and /etc/pki/rpm-gpg already exist
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-CES':
    ensure => present,
    source => "http://yum.centreon.com/standard/3.4/el${::operatingsystemmajrelease}/stable/RPM-GPG-KEY-CES",
  }

  exec { 'Centreon import GPG repository key':
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    command   => 'rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CES',
    unless    => 'rpm -q gpg-pubkey-`echo $(gpg --throw-keyids < /etc/pki/rpm-gpg/RPM-GPG-KEY-CES) | cut --characters=11-18 | tr [A-Z] [a-z]`',
    require   => [
      File['/etc/pki/rpm-gpg/RPM-GPG-KEY-CES'],
      File['/etc/yum.repos.d/centreon-stable.repo']
    ],
    logoutput => 'on_failure',
  }

}

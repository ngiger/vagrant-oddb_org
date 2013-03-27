# == Class: oddb_org
#
# Full description of class oddb_org here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { oddb_org:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class oddb_org(
  $destination = "/var/www",
  $pg_base_version  = '8.4.16',
  $pg_server_version  = '8.4.16-r1',
) {
    package{'apache': }
    package {'postgresql-base':
      ensure => $pg_version,
    }  
       
   file{'/etc/localtime':
      ensure => link,
      target => '../usr/share/zoneinfo/Europe/Zurich',
      owner => 'root',
      group => 'root',
      mode  => 0555,
    }
}

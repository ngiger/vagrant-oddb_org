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
  $destination        = "/var/www",
  $pg_base_version    = '8.4.16',
  $pg_server_version  = '8.4.16-r1',
  $ruby_version       = '1.9.3',
  # if we prepend with /usr/local/lib/rbenv/env/shims: rbenv would be activated, too
  # next without rbenv
  $path               = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.3'
  # puppet has a special version of ruby 1.9.3 installed using rbenv
  # rbenv insists into adding export RUBYOPT='-rauto_gem' to /etc/profile.env
  # when running ruby programs we have to add a RUBYOPT='' at the beginning of each shell which will call a ruby executable
  # or via an environment parameter to the command
  #  $path               = '/usr/local/lib/rbenv/env/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.3:/usr/local/lib/rbenv/bin'
) {
    package{'apache': }
    package {'postgresql-base':
      ensure => $pg_version,
    }  
       
   file{'/etc/localtime':
      ensure => link,
      target => '/usr/share/zoneinfo/Europe/Zurich',
      owner => 'root',
      group => 'root',
      mode  => 0555,
    }
    
}

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
  $select_ruby_1_9    = 'eselect_ruby_1_9',
  $server_name        = hiera('::oddb_org::hostname', '198.168.0.1'),
  $path               = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.3'
) {
    package{['apache', 'etckeeper']: }
    package {'postgresql-base':
      ensure => $pg_version,
    }  
       
    file { '/etc/puppet/hiera.yaml':
      ensure => link,
      target => '/etc/puppet/hieradata/hiera.yaml',
      owner => 'root',
      group => 'root',
      mode  => 0444,
    }
    
    user{'postgres':
      ensure => present,
      system => true,
    }     
  
    host { "$server_name":
      ensure       => present,
      ip           => hiera('::oddb_org::ip', '198.168.0.1'),
      comment      => "Needed to run bin/oddb",
      provider     => augeas,
    }

   file{'/etc/localtime':
      ensure => link,
      target => '/usr/share/zoneinfo/Europe/Zurich',
      owner => 'root',
      group => 'root',
      mode  => 0555,
    }
    
  $select_ruby_1_9_okay = "/opt/${select_ruby_1_9}.okay"
  exec {"$select_ruby_1_9":
    command => "eselect ruby set ruby19 && touch $select_ruby_1_9_okay",
    user => 'root',
    creates => "$select_ruby_1_9_okay",
    path => "$path",
  }

  
  exec {"init_etckeeper":
    command => "etckeeper init -d /etc",
    user => 'root',
    creates => "/etc/.git",
    path => "$path",
  }
}

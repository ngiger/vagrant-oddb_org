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
  $ODDB_HOME          = '/var/www/oddb.org',
  $pg_base_version    = '8.4.17',
  $pg_server_version  = '8.4.17',
  $apache_version     = '2.2.24',
  $ruby_version       = '1.9.3',
  $select_ruby_1_9    = 'eselect_ruby_1_9',
  $server_name        = hiera('::oddb_org::hostname', '198.168.0.1'),
  $path               = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin:/usr/x86_64-pc-linux-gnu/gcc-bin/4.6.3',
  $oddb_user          = 'apache',
  $oddb_group         = 'oddb',
  $inst_logs          = '/opt/logs',
  $create_service_script = '/usr/local/bin/create_service.rb',
  $service_path          = '/var/lib/service'
) {

    package{'daemontools': }
    package{'librarian-puppet':
      provider => gem,
    }
    define oddb_org::add_service($svc_path = $oddb_org::service_path, $working_dir, $user, $exec, $arguments) {
      file {"$svc_path/$title":
        ensure => directory
      }
      file{"$svc_path/$title/run":
        ensure  => present,
        mode    => 0754,
        content => template('oddb_org/service_run.erb'),
        require => File["$svc_path/$title"],
      }
      service{"$title":
        ensure => running,
        provider => "daemontools",
        path    => "$service_path",
        hasrestart => true,
        subscribe  => File["$svc_path/$title/run"],
        require    => File["$svc_path/$title/run"],
      }
    }    
    $rc_svscan          = '/etc/init.d/svscan'
    exec{ "$rc_svscan":
      command => "/sbin/rc-update add svscan && $rc_svscan restart",
      require => [
        Package['daemontools'],
      ],
      onlyif => "/bin/ps -ef | /bin/grep svscan | grep -v grep; /usr/bin/test $? -ne 0",
      user => 'root', # need to be root to (re-)start yus
    }
    
    service{"svscan":
      provider => gentoo,
      require => Exec["$rc_svscan"],
      status => running,
    }

    file {'/var/lib/service':
      ensure => directory,
      mode  => 0644,
    }

    file { "$create_service_script":
      source => "puppet:///modules/oddb_org/create_service.rb",
      mode  => 0774,
      require => [Package['apache'], File['/var/lib/service'],
      ],
    }

    # To be able to read the /run/postgresql directory, the apache user must belong
    # to the group postgres. (Nota bene: all oddb processes run as apache
    user{'apache': 
      groups  => ['postgres'],
      require => Package['apache'],
    }    
    
    if !defined(Group['apache']) {
      group{'apache': require => Package['apache']}
    }
    
    package{'apache':
      ensure => "$apache_version",
    }
    
    package{[
      'etckeeper',  # nice to have a git based history of the /etc 
      'htop',       # Niklaus likes it better than top
      ]: 
    }
    
    package {'postgresql-base':
      ensure => $pg_version,
    }  

    user{'postgres':
      ensure => present,
      system => true,
    }
    
    if ("$oddb_user" != "apache") {
      user{"$oddb_user":
        ensure => present,
        system => false,
        password => "1234",
      }     
    }
    
    group{"$oddb_group":
      ensure => present,
      system => false,
    }     
          
    $email_user     = hiera('::oddb_org::mail::user',      'put your username into hiera-data/private/config.yaml')
    file{ '/etc/gitconfig':
    content => "# Managed by puppet vagrant
[user]
  name = Vagrant-oddb
  email = $email_user
",
    }

    file{'/etc/conf.d/keymaps':
      ensure => present,
      content => '# Managed by puppet
keymap="us"
windowkeys="YES"
extended_keymaps=""
dumpkeys_charset=""
fix_euro="yes"
',
      owner => 'root',
      group => 'root',
      mode  => 0644,
    }
    
   file{'/etc/localtime':
      ensure => link,
      target => '/usr/share/zoneinfo/Europe/Zurich',
      owner => 'root',
      group => 'root',
      mode  => 0644,
    }
    
  file { "$inst_logs":
    ensure => directory,
    mode   => 0666, # writable for everybody
  }
  
  $select_ruby_1_9_okay = "$inst_logs/${select_ruby_1_9}.okay"
  exec {"$select_ruby_1_9":
    command => "eselect ruby set ruby19 && touch $select_ruby_1_9_okay",
    user => 'root',
    creates => "$select_ruby_1_9_okay",
    path => "$path",
    require => File["$inst_logs", '/etc/gitconfig'],
  }

  file {'/etc/cron.daily/etckeeper':
  content => '#!/bin/sh
# managed by vagrant-oddb. copied from Debian
set -e
if [ -x /usr/bin/etckeeper ] && [ -e /etc/etckeeper/etckeeper.conf ]; then
        . /etc/etckeeper/etckeeper.conf
        if [ "$AVOID_DAILY_AUTOCOMMITS" != "1" ]; then
                # avoid autocommit if an install run is in progress
                lockfile=/var/cache/etckeeper/packagelist.pre-install
                if [ -e "$pe" ] && [ -n "$(find "$lockfile" -mtime +1)" ]; then
                        rm -f "$lockfile" # stale
                fi
                if [ ! -e "$lockfile" ]; then
                        AVOID_SPECIAL_FILE_WARNING=1
                        export AVOID_SPECIAL_FILE_WARNING
                        if etckeeper unclean; then
                                etckeeper commit "daily autocommit" >/dev/null
                        fi
                fi
        fi
fi',
    mode => 0755,
}

  exec {"init_etckeeper":
    command => "ln /var/lib/portage/world /etc/world && etckeeper init -d /etc && etckeeper commit 'first commit'",
    user => 'root',
    creates => "/etc/world",
    path => "$path",
    require => Package["etckeeper"],
  }

}


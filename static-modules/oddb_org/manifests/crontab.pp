# Here we define all needed stuff to configure the crontab server
# for ODDB.org

class oddb_org::crontab(
) inherits oddb_org {

  ensure_packages(['cronbase', 'vixie-cron', 'syslog-ng', 'logrotate', 'ntp'])
  service{'vixie-cron':
    ensure => running,
    require => Package['vixie-cron'],
  }
  
  define oddb_org::crontab::add_crontab(
    $job_path     = '/etc/cron.daily', 
    $working_dir  = "$ODDB_HOME", 
    $user         = "$oddb_user",
    $exec         = "$ODDB_HOME/bin/$title &>/dev/null",
  ) {

    file{"$job_path/$title":
      ensure  => present,
      mode    => 0754,
      content => template('oddb_org/crontab_job.erb'),
    }
  }
  
  # daily jobs
  cron { logrotate:  command => "/usr/sbin/logrotate  /etc/logrotate.conf",  user    => root,
    hour    => 2,  minute  => 0
  }
  
  $log_dir = "/var/log/oddb.org"
  file { $log_dir:
    ensure => directory,
    owner => $oddb_user,
  }
	notify { "export_daily with $ODDB_HOME/bin/$title user $oddb_user": }
  cron{'export_daily2':
    command => "$ODDB_HOME/bin/$title xx >$log_dir/$title.log",
    user => $oddb_user, minute => 1, hour => 0}
  cron{'export_fachinfo_yaml':
    command => "$ODDB_HOME/bin/$title >$log_dir/$title.log 2>&1",
    user => $oddb_user, minute => 1, hour => 2, monthday => 28}
  cron{'export_patinfo_yaml':
    command => "$ODDB_HOME/bin/$title >$log_dir/$title.log 2>&1",
    user => $oddb_user, minute => 1, hour => 3, monthday => 27}
  cron{'import_daily':
    command => "$ODDB_HOME/bin/$title >$log_dir/$title.log 2>&1",
    user => $oddb_user, minute => 1, hour => 4}
  cron{'mail_index_therapeuticus_csv':
    command => "$ODDB_HOME/bin/$title >$log_dir/$title.log 2>&1",
    user => $oddb_user, minute => 1, hour => 5, monthday => 25, month => 8}

  # seldom running jobs via cron
  # run ch.oddb migel-products updates 1st of January and 1st of June (run the BAG update via NovaCantica manually)
  oddb_org::crontab::add_crontab{'update_migel_products_with_report': job_path => '/usr/local/bin' }

  cron { bag_update_january:
    command   => "/usr/local/bin/update_migel_products_with_report",
    user      => $oddb_user,
    hour      => 0,
    minute    => 1,
    monthday  => 1,
    month     => 1,    
  }
  cron { bag_update_june:
    command   => "/usr/local/bin/update_migel_products_with_report",
    user      => $oddb_user,
    hour      => 0,
    minute    => 1,
    monthday  => 1,
    month     => 6,    
  }
  
 # missing /usr/local/sbin/ywesee-backup
 # missing /usr/local/bin/update_vhost_stats

  
  file { "/usr/local/bin/ruby":
    ensure => '/usr/bin/ruby',    
  }
  file { "/usr/local/bin/ruby193":
    ensure => '/usr/bin/ruby',    
  }
  
  file {'/etc/logrotate.d/oddb':
    mode => 0644,
    content => "
/var/log/oddb/*
{
        rotate 7
        olddir /var/log/oddb/old
        daily
        missingok
        notifempty
        delaycompress
        compress
}
",
  }
  
  file {'/etc/logrotate.d/rsyslog':
    mode => 0644,
    content => "/var/log/syslog
{
        rotate 7
        daily
        missingok
        notifempty
        delaycompress
        compress
        postrotate
                kill -HUP $(cat /run/rsyslogd.pid) &>/dev/null || true
        endscript
}

/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
{
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                kill -HUP $(cat /run/rsyslogd.pid) &>/dev/null || true
        endscript
}
",
  }

}

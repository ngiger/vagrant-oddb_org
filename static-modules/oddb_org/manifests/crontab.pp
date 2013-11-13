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
    $exec         = 'bundle install &>/dev/null && bundle exec ruby', 
    $arguments    = "jobs/$title") {

    file{"$job_path/$title":
      ensure  => present,
      mode    => 0754,
      content => template('oddb_org/crontab_job.erb'),
    }
  }
  
  # daily jobs
  oddb_org::crontab::add_crontab{'export_daily': }
  oddb_org::crontab::add_crontab{'export_fachinfo_yaml': }
  oddb_org::crontab::add_crontab{'export_patinfo_yaml': }
  oddb_org::crontab::add_crontab{'import_daily': }
  oddb_org::crontab::add_crontab{'mail_index_therapeuticus_csv': }

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

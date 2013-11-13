# Here we define all needed stuff to configure the crontab server
# for ODDB.org

class oddb_org::crontab(
) inherits oddb_org {

  ensure_packages(['vixie-cron', 'syslog-ng', 'logrotate', 'ntp'])
  
  define oddb_org::crontab::add_crontab($job_path = '/etc/cron.daily', $working_dir, $user, $exec, $arguments) {
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

  file { "/usr/local/bin/ruby":
    ensure => '/usr/bin/ruby',    
  }
  file { "/usr/local/bin/ruby193":
    ensure => '/usr/bin/ruby',    
  }
  
  file { "/etc/crontab":
    source => "puppet:///modules/oddb_org/crontab.txt",
    mode  => 0644,
    require =>  Package['vixie-cron'],
  }
 
  file {'/etc/logrotate.d/oddb':
    chmod => 0644,
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
    chmod => 0644,
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
/var/log/messages
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
  
 exec { "crontab /etc/crontab":
  path   => "/usr/bin:/usr/sbin:/bin",
  require => [File['/etc/crontab', '/etc/logrotate.d/rsyslog', '/etc/logrotate.d/oddb'],],
 }
 # missing /usr/local/sbin/ywesee-backup
 # missing /usr/local/bin/update_vhost_stats

}

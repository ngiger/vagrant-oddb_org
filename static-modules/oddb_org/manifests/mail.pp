# configure mail for ODDB via a gmail account

class { 'git': }
class oddb_org::mail(
  $email_user     = hiera('::oddb_org::mail::user',      'put your username into hieradata/private/config.yaml'),
  $mail_to        = hiera('::oddb_org::mail_to',         'put mail_to  into hieradata/private/config.yaml'),
  $email_password = hiera('::oddb_org::mail::password',  'put your password into hieradata/private/config.yaml'),
  $mail_smtp_host = hiera('::oddb_org::mail::smtp_host', 'put your smtp_host into hieradata/private/config.yaml'),
  $flickr_shared_secret = hiera('::oddb_org::flickr_shared_secret', 'put your flickr_shared_secret into hieradata/private/config.yaml'),
  $flickr_api_key       = hiera('::oddb_org::flickr_api_key',       'put your flickr_api_key into hieradata/private/config.yaml'),
  $hostname             = hiera('::oddb_org::hostname',      'put your hostname into hieradata/private/config.yaml'),
  $oddb_yml = "$oddb_home/etc/oddb.yml", # needed of oddb_org::all
 
) inherits oddb_org::oddb_git {
  $mail_package = 'ssmtp'
  file { '/etc/puppet/private':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
 
  file { '/etc/ssmtp/revaliases':
  content => "# Managed by puppet oddb_org/manifests/mail.pp
root:${email_user}
vagrant:${email_user}
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => Package[$mail_package],
}
 
  package{"$mail_package": }
  file { '/etc/ssmtp/ssmtp.conf':
    content => "# Managed by puppet oddb_org/manifests/mail.pp
root=${email_user}
mailhub=${mail_smtp_host}
rewriteDomain=ngiger.dyndns.org
hostname=${mail_smtp_host}
UseSTARTTLS=YES  
AuthUser=${email_user}
AuthPass=${email_password}
FromLineOverride=Yes
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => Package[$mail_package],
}
   
  file {"$oddb_yml" :
    content => template('oddb_org/oddb.yml.erb'),
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => [ Vcsrepo["$oddb_home"], Package[$mail_package], ]
}
  

  # test_enrionments reads email_address via git. Therefore we need configure git for it
  $mail_configured = "$inst_logs/mail_server.okay"
  exec{ "$mail_configured":
    command => "/bin/bash -c 'export HOME=$inst_logs && git config --global user.email \"$mail_to\" && touch $mail_configured'",
    creates => "$mail_configured",
    path => "$path",
    user => "$oddb_user",
    cwd => "$inst_logs",
    require => File[$inst_logs, $oddb_yml],
  }
  
}

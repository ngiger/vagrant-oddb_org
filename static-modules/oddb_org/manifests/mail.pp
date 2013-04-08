# configure mail for ODDB via a gmail account

class { 'git': }
class oddb_org::mail(
  $email_user     = hiera('::oddb_org::mail::user',      'put your username   into /tmp/hiera-data/private/config.yaml'),
  $email_password = hiera('::oddb_org::mail::password',  'put your password   into /tmp/hiera-data/private/config.yaml'),
  $mail_smtp_host = hiera('::oddb_org::mail::smtp_host', 'put your smtp_host  into /tmp/hiera-data/private/config.yaml'),
  
) inherits oddb_org {
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
  
  # test_enrionments reads email_address via git. Therefore we need configure git for it
  $mail_configured = "/opt/mail_server.okay"
  exec{ "$mail_configured":
    command => "git config --global user.email $email_user && touch $mail_configured",
    creates => "$mail_configured",
    path => "$path",
  }
  
}

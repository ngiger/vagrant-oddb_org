# configure mail for ODDB via a gmail account

class { 'git': }
class oddb_org::mail(
  $email_user     = hiera('::oddb_org::mail::user',      'put your username   into /tmp/hiera-data/private/config.yaml'),
  $email_password = hiera('::oddb_org::mail::password',  'put your password   into /tmp/hiera-data/private/config.yaml'),
  $mail_smtp_host = hiera('::oddb_org::mail::smtp_host', 'put your smtp_host  into /tmp/hiera-data/private/config.yaml'),
  $oddb_yml = "$ODDB_HOME/etc/oddb.yml", # needed of oddb_org::all
  
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
    content => "# Managed by puppet oddb_org/manifests/mail.pp
smtp_server: ${mail_smtp_host}
smtp_domain: ywesee.com
smtp_user: ${email_user}
smtp_pass: ${email_password}
smtp_port: 587
url_bag_sl_zip: http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip
mail_from: '\"localtest Zeno\" <${email_user}>'
mail_to:    [ ${email_user} ] # must be an array!
text_info_newssource:  http://www.documed.ch/de/xml/fastonline.rss.php
text_info_newssource2: http://compendium.ch/update/de
text_info_searchform:  http://classic.compendium.ch/Search.aspx?lang=de
text_info_searchform2: http://compendium.ch/search/de
testenvironment1: /var/www/oddb.org/test/testenvironment1.rb
testenvironment2: /var/www/oddb.org/test/testenvironment2.rb
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => [ Vcsrepo["$ODDB_HOME"], Package[$mail_package], ]
}
  

  # test_enrionments reads email_address via git. Therefore we need configure git for it
  $mail_configured = "$inst_logs/mail_server.okay"
  exec{ "$mail_configured":
    command => "/bin/bash -c 'export HOME=$inst_logs && git config --global user.email $email_user && touch $mail_configured'",
    creates => "$mail_configured",
    path => "$path",
    user => "$oddb_user",
    cwd => "$inst_logs",
    require => File[$inst_logs, $oddb_yml],
  }
  
}

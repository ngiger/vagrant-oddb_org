# Here we define all needed stuff to configure the migel
# for ODDB.org 

class oddb_org::migel(
  $email_user     = hiera('::oddb_org::mail::user',      'put your username   into /tmp/hiera-data/private/config.yaml'),
  $email_password = hiera('::oddb_org::mail::password',  'put your password   into /tmp/hiera-data/private/config.yaml'),
  $mail_smtp_host = hiera('::oddb_org::mail::smtp_host', 'put your smtp_host  into /tmp/hiera-data/private/config.yaml'),
) inherits oddb_org {
  include oddb_org::pg

  # we need to install migel
  $migel_git = '/var/www/migel'
  vcsrepo {"$migel_git":
      ensure => present,
      provider => git,
      source => 'git://scm.ywesee.com/migel',
      require => [User['apache'],],
  }  
  
  $DB_NAME= 'migel'
  $DB_DUMP= '/vagrant/db_dumps/pg-db-migel-backup.gz'
  
  $pg_migel_db_load_script = "/usr/local/bin/pg_create_migel_db.sh"
  file { "$pg_migel_db_load_script":
    content => template("oddb_org/pg_create_db.sh.erb"),
    owner => 'postgres',
    group => 'postgres',
    mode  => 0554,
    require => [Package['apache', 'postgresql-server'], ],
    notify => [Service['postgresql-8.4'], Exec["$pg_migel_db_load_script"]],
  }
  
  $pg_migel_loaded = "/opt/pg_migel_loaded.okay"
  exec{ "$pg_migel_db_load_script":
    command => "$pg_migel_db_load_script && touch $pg_migel_loaded",
    creates => "$pg_migel_loaded",
    require => [ 
      Service['postgresql-8.4'],
      File["$pg_migel_db_load_script"] 
    ],
    path => "$path",
    timeout => 15*160, # max wait time in seconds, took just above default 5 minutes on my machine
  }
  
  $migel_name     = "migeld"
  $migel_run      = "/var/lib/service/$migel_name/run"
  exec{ "$migel_run":
    command => "$create_service_script $oddb_user $migel_name '$migel_git/bin/migeld'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      Vcsrepo["$migel_git"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$migel_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  $migel_yml = '/etc/migel/migel.yml'
  file{'/etc/migel':
    ensure => directory,
  }
  
  file {"$migel_yml" :
    content => "# Managed by puppet migel_org/manifests/migel.pp
---
db_name: 'migel'
db_user: 'postgres'
db_auth: ''

admins:
# - yasaka@ywesee.com
# - zdavatz@ywesee.com
mail_from: '\"localtest Zeno\" <${email_user}>'
mail_to:    ${email_user}
smtp_server: ${mail_smtp_host}
smtp_domain: ywesee.com
smtp_user: ${email_user}
smtp_pass: ${email_password}
smtp_port: 587
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => [ Vcsrepo["$migel_git"], File['/etc/migel'] ]
}
  
  service{"$migel_name":
    ensure => running,
    provider => "daemontools",
    path    => "$service_path",
    hasrestart => true,
    subscribe  => [ Exec["$migel_run"] ],
    require    => [ User['apache'], Exec["$migel_run"], ],
  }

}

# Here we define all needed stuff to configure the migel
# for ODDB.org 

class oddb_org::migel(
  $email_user     = hiera('::oddb_org::mail::user',      'put your username into hiera-data/private/config.yaml'),
  $email_password = hiera('::oddb_org::mail::password',  'put your password into hiera-data/private/config.yaml'),
  $mail_smtp_host = hiera('::oddb_org::mail::smtp_host', 'put your smtp_host into hiera-data/private/config.yaml'),
  $mail_to        = hiera('::oddb_org::mail_to',         'put mail_to  into hiera-data/private/config.yaml'),
) inherits oddb_org {
  include oddb_org::pg
  include oddb_org::yus

  # we need to install migel
  $migel_git = '/var/www/migel'
  vcsrepo {"$migel_git":
      ensure => present,
      provider => git,
      source => 'https://github.com/zdavatz/migel.git',
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

  $migel_bundle_installed = "/opt/migel_bundle_installed.okay"
  exec{ "$migel_bundle_installed":
    cwd     => "$migel_git",
    command => "bundle install && touch $migel_bundle_installed",
    creates => "$migel_bundle_installed",
    require => [ 
      Vcsrepo["$migel_git"],
    ],
    path => "$path",
  }
  
  $migel_yml = '/etc/migel/migel.yml'
  file{'/etc/migel':
    ensure => directory,
  }
  
  file {"$migel_yml" :
    content => template('oddb_org/migel.yml.erb'),
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => [ Vcsrepo["$migel_git"], File['/etc/migel'] ]
  }
  
  oddb_org::add_service{"migeld":
    working_dir => "$migel_git",
    user        => "$oddb_user",
    exec        => 'bundle exec ruby',
    arguments   => 'bin/migeld',
    require     => [Service['yus'], Vcsrepo["$migel_git"], File["$migel_yml"], User['apache'], Exec["$pg_migel_db_load_script"], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
}

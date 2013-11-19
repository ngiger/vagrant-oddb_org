# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class oddb_org::oddb_git(
  $SETUP_DIR = '/home/vagrant/oddb_setup',
  $bundle_oddb_org =  "$inst_logs/oddb_bundle_install.okay"
) inherits oddb_org::pg {
  
  vcsrepo {  "$ODDB_HOME":
      ensure => present,
      provider => git,
      owner => "$oddb_user",
      group => "apache",
      source => "https://github.com/zdavatz/oddb.org.git",
      require => [User['apache'],],
  }  
  
  ensure_packages(['mailx'])
  package{ 'yus':
    provider => gem,
  }
  
  file { ["$ODDB_HOME/doc", "$ODDB_HOME/data", "$ODDB_HOME/log", "$ODDB_HOME/data/html",
    "$ODDB_HOME/data/html/fachinfo", "$ODDB_HOME/data/html/fachinfo/de", "$ODDB_HOME/data/html/fachinfo/fr","$ODDB_HOME/data/html/fachinfo/en",
    "$ODDB_HOME/data/html/patinfo",  "$ODDB_HOME/data/html/patinfo/de",  "$ODDB_HOME/data/html/patinfo/fr","$ODDB_HOME/data/html/patinfo/en",
  ]:
    ensure  => directory,
    owner => "$oddb_user",
    group => "apache",
    mode    => 0664, # must be writable for $oddb_user and apache
    require => Vcsrepo["$ODDB_HOME"],
  }
  package{ 'bundler':  provider => gem, }
   
  package{ 'tmail': provider => portage }
   
  package{ 'eselect-ruby': }
  $ruby_installed = "$inst_logs/two_rubies_installed.okay"
  # we need libyaml for YAML syck to work correctly
  exec { "$ruby_installed":
    command => "emerge libyaml ruby:1.8  ruby:1.9 eselect-ruby && touch $ruby_installed",
    creates => "$ruby_installed",
    path => "$path",
  }
   
  package{'imagemagick':}  # needed for gem rmagick
  
  exec { "$bundle_oddb_org":
    command => "eselect ruby set ruby19 && bundle install && touch $bundle_oddb_org",
    creates => "$bundle_oddb_org",
    cwd => "$ODDB_HOME",
    path => "$path",
    require => [  Package['bundler', 'imagemagick', 'tmail'],
    Vcsrepo[$ODDB_HOME],
    
    ],
  }

  $oddb_setup_run = 'run_oddb_setup.sh'
  $oddb_setup_sh  = '/usr/local/bin/oddb_setup.sh'
  $oddb_setup_okay = "$inst_logs/oddb_setup.okay"
  file { "$oddb_setup_sh":
    content => template('oddb_org/oddb_setup.sh.erb'),
    owner => 'root',
    group => 'root',
    mode  => 0754,
    notify => [Exec["$oddb_setup_run"], ],
  }

  exec {"$oddb_setup_run":
    command => "$oddb_setup_sh && touch $oddb_setup_okay",
    path => "$path",
    creates => $oddb_setup_okay,
    require => [  File[ "$oddb_setup_sh"], 
        Exec["$ruby_installed", "$select_ruby_1_9"],
        Vcsrepo[$ODDB_HOME], 
        Service['postgresql-8.4'],
    ],
  }
  
  file { "$ODDB_HOME/src/testenvironment.rb":
    source => "puppet:///modules/oddb_org/testenvironment_rb.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  file { "$ODDB_HOME/etc/db_connection.rb":
    source => "puppet:///modules/oddb_org/db_connection.rb.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  oddb_org::add_service{"oddb":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => 'bundle exec ruby',
    arguments   => 'bin/oddbd',
    memory_ulimit => '10240000',
    require     => [Service['yus'], User['apache'], Exec["$oddb_setup_run"], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
}
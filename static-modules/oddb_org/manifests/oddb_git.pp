# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class oddb_org::oddb_git(
  $SETUP_DIR = '/home/vagrant/oddb_setup',
  $bundle_oddb_org =  "$inst_logs/oddb_bundle_install.okay"
) inherits oddb_org::pg {
  
  vcsrepo {  "$oddb_home":
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
  
  file { ["$oddb_home/doc", "$oddb_home/data", "$oddb_home/log", "$oddb_home/data/html",
    "$oddb_home/data/html/fachinfo", "$oddb_home/data/html/fachinfo/de", "$oddb_home/data/html/fachinfo/fr","$oddb_home/data/html/fachinfo/en",
    "$oddb_home/data/html/patinfo",  "$oddb_home/data/html/patinfo/de",  "$oddb_home/data/html/patinfo/fr","$oddb_home/data/html/patinfo/en",
  ]:
    ensure  => directory,
    owner => "$oddb_user",
    group => "apache",
    mode    => 0664, # must be writable for $oddb_user and apache
    require => Vcsrepo["$oddb_home"],
  }
  package{ 'bundler':  provider => gem, }
   
  package{ 'eselect-ruby': }
  $ruby_installed = "$inst_logs/two_rubies_installed.okay"
  # we need libyaml for YAML syck to work correctly
  exec { "$ruby_installed":
    command => "emerge libyaml ruby:1.8  ruby:1.9 eselect-ruby && touch $ruby_installed",
    creates => "$ruby_installed",
    path => "$path",
  }
  package{'ghostscript-gpl':}  # needed for displaying tageskosten
  # As seen in http://dev.ywesee.com/Niklaus/20140113-hpc-error we should emerge imagemagick with
  portage::package { 'media-gfx/imagemagick':
    use     => ['png', 'jpeg', 'truetype'],
    ensure  => present,
  }
  portage::package { 'sys-kernel/debian-sources':
    use     => ['binary'],
    ensure  => present,
  }
  
  exec { "$bundle_oddb_org":
    command => "eselect ruby set ruby19 && git pull && bundle install && touch $bundle_oddb_org",
    creates => "$bundle_oddb_org",
    cwd => "$oddb_home",
    path => "$path",
    require => [Portage::Package['media-gfx/imagemagick'], [  Package['bundler']],
    Vcsrepo[$oddb_home],
    
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
        Vcsrepo[$oddb_home],
        Service['postgresql-8.4'],
    ],
  }
  
  file { "$oddb_home/src/testenvironment.rb":
    source => "puppet:///modules/oddb_org/testenvironment_rb.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  file { "$oddb_home/etc/db_connection.rb":
    source => "puppet:///modules/oddb_org/db_connection.rb.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  oddb_org::add_service{"ch.oddb":
    working_dir => "$oddb_home",
    user        => "$oddb_user",
    exec        => '/usr/local/bin/ruby',
    arguments   => 'bin/oddbd',
    memory_ulimit => '10240000',
    require     => [Service['yus'], User['apache'], Exec["$oddb_setup_run"], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
}
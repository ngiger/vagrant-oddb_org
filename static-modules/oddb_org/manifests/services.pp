# Here we define all needed stuff to configure the services
# for ODDB.org (yus, oddb, currency have separate pp files)

class oddb_org::services(
) inherits oddb_org {
  require oddb_org::yus
  # not active anymore 
  # * analysisparse
  # * readonly
  # * fipdf
  
  package{['rwv2', 'ydocx', 'rpdf2txt']:
    provider => gem,
    require => Exec["$select_ruby_1_9"],
  }
    
  # we need to compile and install rwv2
  $rwv2_git = '/opt/src/rwv2'
  vcsrepo {"$rwv2_git":
      ensure => present,
      provider => git,
      source => 'git://scm.ywesee.com/rwv2',
      require => [User['apache'],],
  }  
  $exec_cmd = '/usr/local/bin/ruby'
  exec{ "install_rwv2":
    command => "ruby19 install.rb config && ruby19 install.rb setup && ruby19 install.rb install",
    cwd => "$rwv2_git",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => Vcsrepo["$rwv2_git"],
    creates => "/usr/lib64/ruby/site_ruby/1.9.1/x86_64-linux/rwv2.so",
  }

  oddb_org::add_service{"ch.oddb-crawler":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'bin/oddbd crawler',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }

  oddb_org::add_service{"ch.oddb-export":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/export/bin/exportd',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }

  oddb_org::add_service{"ch.oddb-fiparse":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/fiparse/bin/fiparsed',
    require     => [Service['yus'], User['apache'], Package['daemontools', 'ydocx', 'rpdf2txt'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }

  oddb_org::add_service{"oddb_google_crawler":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'bin/oddbd google_crawler',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
  
  oddb_org::add_service{"ch.oddb-meddata":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/meddata/bin/meddatad',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }

  oddb_org::add_service{"ch.oddb-swissindex_nonpharma":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/swissindex/bin/swissindex_nonpharmad',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
    
  oddb_org::add_service{"ch.oddb-swissindex_pharma":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/swissindex/bin/swissindex_pharmad',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
  
  oddb_org::add_service{"ch.oddb-swissreg":
    working_dir => "$ODDB_HOME",
    user        => "$oddb_user",
    exec        => $exec_cmd,
    arguments   => 'ext/swissreg/bin/swissregd',
    require     => [Service['yus'], User['apache'], ],
    subscribe   => Service['yus'], # , 'oddb'
  }
}

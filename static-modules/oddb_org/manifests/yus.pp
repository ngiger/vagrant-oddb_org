# Here we define all needed stuff to configure the yus server
# for ODDB.org

class oddb_org::yus(
  $username   = hiera('::oddb_org::username', 'dummy_user'),
  $root_name  = hiera('::oddb_org::root_name', 'dummy_root'),
  $root_pw    = hiera('::oddb_org::root_pw', 'dummy_root_pw'),
  $yus_root   = "/etc/yus",
  $yus_data   = "/etc/yus/data",
  $yus_grant_user = "$inst_logs/yus_grant_user.okay", # needed for oddb_org::all
  $sha_cmd        = "/usr/local/bin/sha256.rb"
) inherits oddb_org::pg {

  # run RUBYOPT=-rauto_gem rvm system do ruby /usr/local/bin/dbi_test.rb
  file {'/usr/local/bin/dbi_test.rb':
    source => "puppet:///modules/oddb_org/dbi_test.rb",
      owner => "$oddb_user",
      group => "$oddb_group",
      require => [ User["$oddb_user"], Group["$oddb_group"], ],
      mode => '0775',
  }
    
  file {"$yus_root":
    ensure => directory,
      recurse => true,
      owner => "$oddb_user",
      group => "$oddb_group",
      require => [ User["$oddb_user"], Group["$oddb_group"], ],
  }
    
  file {"$yus_data":
    ensure => directory,
      owner => "$oddb_user",
      group => "$oddb_group",
      require => [ User["$oddb_user"], Group["$oddb_group"],File["$yus_root"] ],
  }
    
  file {"$sha_cmd":
      content => "#!/usr/bin/env ruby
require 'digest/sha2'
print Digest::SHA256.hexdigest(ARGV[0]),\"\\n\"
",    
      owner => "$oddb_user",
      group => "$oddb_group",
      mode => '0775',
  }
  
  $yus_install_script = '/usr/local/bin/install_yus.sh'
  $service_location = "/usr/local/bin/yusd"
  $service_user     = "root"
  $install_yus_okay = "$inst_logs/install_yus.okay"
  exec{ "$yus_install_script":
    command => "$yus_install_script && touch $install_yus_okay",
    path => '/usr/local/bin:/usr/bin:/bin',
    require   => [File["$yus_root", "$yus_data", $yus_install_script], # "$service_location"],
    ],
    subscribe => File["$yus_install_script" ],
    creates => "$install_yus_okay",
    user => 'root',
  }

  $yus_db_create_script = '/usr/local/bin/yus_db_created.sh'
  file {"$yus_db_create_script":
      content => "#!/bin/bash -v
whoami
dropdb yus
dropuser yus
createuser yus --superuser
createdb yus
exit 0",
      owner => "$oddb_user",
      group => "$oddb_group",
      require => User["$oddb_user"],
      mode => '0775',
  }
  $yus_db_created = "$inst_logs/yus_db_created.okay"
  exec{ "$yus_db_created":
    command => "$yus_db_create_script && touch $yus_db_created",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [File["$yus_db_create_script", "$yus_root", "$yus_data"],
                User["postgres"],
                Service["postgresql-8.4"],
    ],
    creates => "$yus_db_created",
    user => 'postgres',
  }
  
  $yus_create_yml_script = '/usr/local/bin/yus_create_yml.rb'
  file {"$yus_create_yml_script":
      content => template('oddb_org/yus_create_yml.rb.erb'),
      owner => "$oddb_user",
      group => "$oddb_group",
      require => [ User['postgres', "$oddb_user"], Exec["$yus_db_created"], ],
      mode => '0775',
  }
  
  $yus_create_yml = "$yus_root/yus.yml"
  exec{ "$yus_create_yml":
    command => "$yus_create_yml_script",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
        Exec["$yus_db_created"],
    ],
    creates => "$yus_create_yml",
    user => "$oddb_user",
  }
  
  $yus_grant_user_script = '/usr/local/bin/yus_grant_user.rb'
  file {"$yus_grant_user_script":
      content => template('oddb_org/yus_grant_user.rb.erb'),
      owner => "$oddb_user",
      group => "$oddb_group",
      require => [ User["$oddb_user"], Exec["$yus_create_yml"], ],
      mode => '0775',
  }
  
  exec{ "$yus_grant_user":
    command => "$yus_grant_user_script && touch $yus_grant_user",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      Exec["$yus_create_yml"],
      File["$yus_grant_user_script"],
      Service['yus'],
    ],
    tries => 3,     # the yus service is not always ready the first time. Therefore we try it 3 times
    try_sleep => 5, # and wait 5 seconds in between
    subscribe  =>  Service["yus"], 
    creates => "$yus_grant_user",
    user => 'root', # need to be root to (re-)start yus
  }
  
  if ( hiera('::oddb_org::use_yus_19', false)) {
    file { "$yus_install_script":
      source => "puppet:///modules/oddb_org/install_yus19.sh",
        owner => "$oddb_user",
        group => "$oddb_group",
        mode  => 0774,
      require => [Package['apache'], User["$oddb_user"]],
    }

    oddb_org::add_service{'yus':
      working_dir => '/usr/local/src/yus19',
      user        => "$oddb_user",
      exec        => 'bundle exec ruby',
      arguments   => 'bin/yusd',
      require     => [ User["$oddb_user"],Exec["$yus_db_created", "$yus_create_yml"], Service['svscan'] ],
      subscribe   => Exec["$yus_db_created", "$yus_install_script", "$yus_create_yml"],
    }
  }
  else {
    file { "$yus_install_script":
      source => "puppet:///modules/oddb_org/install_yus18.sh",
        owner => "$oddb_user",
        group => "$oddb_group",
        mode  => 0774,
      require => [Package['apache'], User["$oddb_user"]],
    }
    oddb_org::add_service{'yus':
      working_dir => '/usr/local/src/yus18',
      user        => "$oddb_user",
      exec        => 'ruby18 /usr/local/ruby18/bin/bundle exec ruby18 ',
      arguments   => 'bin/yusd',
      require     => [ User["$oddb_user"],Exec["$yus_db_created", "$yus_create_yml"], Service['svscan'] ],
      subscribe   => Exec["$yus_db_created", "$yus_install_script", "$yus_create_yml"],
    }
  }  
}

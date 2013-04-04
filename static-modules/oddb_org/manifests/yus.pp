# Here we define all needed stuff to configure the yus server
# for ODDB.org

class oddb_org::yus(
  $username = 'niklaus',
  $root_name = "niklaus@ywesee.com",
  $root_pass = "ec74c79bb6e82b4a0a448f6a1134d8fd4fd3c6ff40fd7ec58adee9805c757c24",
  $yus_ruby_version = '1.8.7_p371',
  $yus_root   = "/etc/yus",
  $yus_data   = "/etc/yus/data"
) inherits oddb_org::pg {

  package{'ruby-password':
    ensure => present,
  }
  
  # Installing yus is done via a script as it is a delicate mix of ruby18/gem18 and emerge!
  $rsa_keyfile = "${yus_data}/${username}_rsa"
  exec{ "$rsa_keyfile":
    command => "ssh-keygen -t rsa -f $rsa_keyfile",
    creates => "$rsa_keyfile",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => File["${yus_data}"],
  }
  
  # run RUBYOPT=-rauto_gem rvm system do ruby /usr/local/bin/dbi_test.rb
  file {'/usr/local/bin/dbi_test.rb':
    source => "puppet:///modules/oddb_org/dbi_test.rb",
      owner => 'postgres',
      group => 'postgres',
      require => User['postgres'],
      mode => '0755',
  }
    
  file {"$yus_root":
    ensure => directory,
      owner => 'postgres',
      group => 'postgres',
      require => User['postgres'],
      mode => '0644',
  }
    
  file {"$yus_data":
    ensure => directory,
      owner => 'postgres',
      group => 'postgres',
      require => [ User['postgres'],  File["$yus_root"] ],
      mode => '0644',
  }
    
  file {'/usr/local/bin/sha256.rb':
      content => "#!/usr/bin/env ruby
require 'digest/sha2'
print Digest::SHA256.hexdigest(ARGV[0]),\"\\n\"
",    
      owner => 'root',
      group => 'root',
      mode => '0755',
  }
  
  $yus_install_script = '/usr/local/bin/install_yus.sh'
  file { "$yus_install_script":
    source => "puppet:///modules/oddb_org/install_yus.sh",
    owner => 'postgres',
    group => 'postgres',
    mode  => 0554,
    require => [Package['apache'], User['postgres']],
    
  }

  $service_location = "/usr/local/bin/yusd"
  exec{ "$service_location":
    command => "$yus_install_script && touch $service_location",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [File["$yus_install_script", "$yus_root", "$yus_data"], ],
    subscribe => File["$yus_install_script" ],
    creates => "/usr/local/bin/yusd",
    user => 'root',
  }
  File["$yus_install_script"] -> Exec["$service_location"]

  $yaml_content = "# Managed by puppet in module oddb_org/manifests/yus.pp
root_name: ${root_name}
root_pass: ${root_pass}
log_level: DEBUG
ssl_key: /etc/yus/data/${username}_rsa
ssl_cert: /etc/yus/data/${username}_rsa.crt
"
  file {'/etc/yus/yus.yml':
      content => "$yaml_content",
      owner => 'root',
      group => 'root',
      mode => '0544',
      require => File["$yus_root"],
  }

  $rsa_certificate = "/etc/yus/data/${username}_rsa.crt"
  exec{ "$rsa_certificate":
    command => "openssl req -new -x509 -key $rsa_keyfile -out $rsa_certificate -batch",
    creates => "$rsa_certificate",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => File["${yus_data}"],
  }

  $yus_db_create_script = '/usr/local/bin/yus_db_created.sh'
  file {"$yus_db_create_script":
      content => "#!/bin/bash -v
whoami
dropuser yus
dropdb yus
createuser yus --superuser
createdb yus
exit",
      owner => 'postgres',
      group => 'postgres',
      require => User['postgres'],
      mode => '0755',
  }
  $yus_db_created = "$yus_data/yus_db_created.okay"
  exec{ "$yus_db_created":
    command => "$yus_db_create_script && touch $yus_db_created",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [File["$yus_db_create_script", "$yus_root", "$yus_data"], User['postgres'],
                Service["postgresql-8.4"],
    ],
    creates => "$yus_db_created",
    user => 'postgres',
  }
  
  $yus_service = '/etc/init.d/yus'
  file{ "$yus_service":
    content => template("oddb_org/yus.erb"),
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  
  service{"yus":
    ensure => running,
    hasrestart => true,
    require => [Exec["$yus_db_created"], ],
    subscribe  => [ Exec["$service_location", "$yus_db_created",  "$service_location" ], 
      File["$yus_service"] 
    ],
  }
  
}

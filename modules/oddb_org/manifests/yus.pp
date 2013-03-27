# Here we define all needed stuff to configure the yus server
# for ODDB.org

class oddb_org::yus(
  $username = 'niklaus',
  $root_name = "niklaus@ywesee.com",
  $root_pass = "ec74c79bb6e82b4a0a448f6a1134d8fd4fd3c6ff40fd7ec58adee9805c757c24",
  $yus_ruby_version = '1.8.7_p371'
) inherits oddb_org {
  # at the moment we assume it as installed!

# package{"ruby":
#    ensure => "$yus_ruby_version",
#  }
# commented out as puppet emerges it each time I call pupet

  package{'ruby-password':
    ensure => present,
  }
  
  package{'dev-ruby/dbi':
    ensure => present,
  }
  
#  package{'dev-ruby/dbd-pg': # cannot be done here as puppet reports
# err: /Stage[main]/Oddb_org::Yus/Package[dev-ruby/dbd-pg]: Could not evaluate: Execution of '/usr/bin/eix --nocolor --pure-packages --stable --format <category> <name> [<installedversions:LASTVERSION>] [<bestversion:LASTVERSION>] <homepage> <description>
# --exact --category-name dev-ruby/dbd-pg' returned 1: 
#    ensure => present,
#    provider => portage,
#  }

  package{'deprecated':
    ensure => absent,
    provider => portage,
  }
  
  package{'pg':
    ensure => absent,
    provider => portage,
  }
  
  $rsa_keyfile = "/etc/yus/data/${username}_rsa"
  exec{ "$rsa_keyfile":
    command => "ssh-keygen -t rsa -f $rsa_keyfile",
    creates => "$rsa_keyfile",
    path => '/usr/local/bin:/usr/bin:/bin',
  }
  
  # run RUBYOPT=-rauto_gem rvm system do ruby /usr/local/bin/dbi_test.rb
  file {'/usr/local/bin/dbi_test.rb':
    source => "puppet:///modules/oddb_org/dbi_test.rb",
      owner => 'postgres',
      group => 'postgres',
      mode => '0755',
  }
    
  file {'/etc/yus':
    ensure => directory,
      owner => 'postgres',
      group => 'postgres',
      mode => '0644',
  }
    
  file {'/etc/yus/data':
    ensure => directory,
      owner => 'postgres',
      group => 'postgres',
      mode => '0644',
      require => File['/etc/yus'],
  }
    
  $yus_checkout = '/opt/src/yus'
  vcsrepo {  "$yus_checkout":
      ensure => present,
      provider => git,
      owner => 'postgres',
      group => 'postgres',
      source => 'git://scm.ywesee.com/yus',
  }  
  
  file {"$yus_checkout":
    ensure => directory,
    recurse => true,
    owner   => 'vagrant',
    group   => 'vagrant',
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
    require => [Package['apache'], ],
  }
  
  $yus_installed = "/usr/local/bin/yusd"
  exec{ "$yus_installed":
    command => "$yus_install_script && touch $yus_installed",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [File["$yus_install_script", '/etc/yus'], ],
    creates => "/usr/local/bin/yusd",
    user => 'root',
  }

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
      require => File['/etc/yus'],
  }

  $rsa_certificate = "/etc/yus/data/${username}_rsa.crt"
  exec{ "$rsa_certificate":
    command => "openssl req -new -x509 -key $rsa_keyfile -out $rsa_certificate -batch",
    creates => "$rsa_certificate",
    path => '/usr/local/bin:/usr/bin:/bin',
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
      mode => '0755',
  }
  $yus_db_created = "/etc/yus/data/yus_db_created.okay"
  exec{ "$yus_db_created":
    command => "$yus_db_create_script && touch $yus_db_created",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [File["$yus_db_create_script", '/etc/yus'], ],
    creates => "$yus_db_created",
    user => 'postgres',
  }
}

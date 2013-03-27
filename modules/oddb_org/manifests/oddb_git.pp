# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class oddb_org::oddb_git(
  $ODDB_HOME = '/var/www/oddb.org',
  $SETUP_DIR = '/home/vagrant/oddb_setup',
) inherits oddb_org::pg {
  
  if !defined(User['apache']) {
    user{'apache': require => Package['apache']}
  }
  if !defined(Group['apache']) {
    group{'apache': require => Package['apache']}
  }
  vcsrepo {  "$ODDB_HOME":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => 'https://github.com/zdavatz/oddb.org.git',
      # cloning via git did not work!
      # source => "git://scm.ywesee.com/oddb.org/.git ",
      require => [User['apache'],],
  }  
  
  package{ 'bundler':
    provider => gem,
   }
   
  exec { 'bundle_oddb_org':
    command => "rvm list && pwd && rvm ruby-1.9.3-p392 do bundle install && touch install.okay",
    creates => "$ODDB_HOME/install.okay",
    cwd => "$ODDB_HOME",
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    require => [  Package['bundler'], # TODO: 'imagemagick'
    Vcsrepo[$ODDB_HOME],
# TODO:    Package['postgresql-base'], 
    ],
  }
  
  $oddb_setup_sh  = '/usr/local/bin/oddb_setup.sh'
  file { "$oddb_setup_sh":
    content => template('oddb_org/oddb_setup.sh.erb'),
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }

  exec { 'run_oddb_setup.sh':
    command => "$oddb_setup_sh",
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    creates => '/opt/oddb_setup.okay',
    require => [  File[ "$oddb_setup_sh"], 
        Vcsrepo[$ODDB_HOME], 
        Service['postgresql-8.4'],
    ],
  }
  

  package{ 'zip': } # needed to rake dbi!
  
  $dbi_root =  "/opt/dbi"
  $install_dbi_cmd = "/usr/local/bin/install_dbi.sh"
  
  file { "$install_dbi_cmd":
    content => template('oddb_org/install_dbi.sh.erb'),
    owner => 'root',
    group => 'root',
    mode  => 0754,
  }
  
  exec  { 'install_dbi':
  command => "$install_dbi_cmd",
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    require => [ File["$install_dbi_cmd"], ],
    creates => '/opt/dbi/gen_gem.okay',
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
  
  # include oddb_org::apache
  
# TODO: 
#  include oddb_org::pg
#  package 'imagemagick':  # needed for gem rmagick
  
 
}
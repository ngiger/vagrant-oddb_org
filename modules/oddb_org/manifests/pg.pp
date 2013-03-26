# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class oddb_org::pg inherits oddb_org {
# puppetlabs-postgresql fails on funtoo
#  class { 'postgresql':
#    version => '8.4', # could not install 8.4.2, neither 8.4.9
#    charset => 'UTF8',
#    locale  => 'de_CH',
#  }
  
#  class { 'postgresql::client':
#    }
  
  package {'postgresql-server':
    ensure => $pg_server_version,
    }  

  file { "/usr/local/bin/pg_create_db.sh":
    content => template("oddb_org/pg_create_db.sh.erb"),
    owner => 'postgres',
    group => 'postgres',
    mode  => 0554,
    require => [Package['apache', 'postgresql-server'], ],
    notify => Service['postgresql-8.4'],
  }
  
  file{'/run/postgresql':
    ensure => directory,
    owner => 'postgres',
    group => 'postgres',
    mode  => 0440,
    require =>  Package['postgresql-server'],                  
  }
  
  $okayConfig = "/opt/pg_server.configured"
  exec{ "$okayConfig":
    command => "echo y | emerge --config dev-db/postgresql-server:8.4 && rc-config add postgresql-8.4 default && touch $okayConfig",
    creates => "$okayConfig",
    require => Package['postgresql-server'],
    notify => Service['postgresql-8.4'],
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
  }
  
  $okayPgDb= "/opt/pg_db.configured"
  exec{ "config_pg_db":
    command => "sudo -u postgres dropdb oddb.org.ruby193; \
    sudo -u postgres psql -c 'drop role oddb;'; \
    sudo -u postgres createdb -E UTF8 -T template0 oddb.org.ruby193 && \
    sudo -u postgres psql -c 'create role oddb;' &&  \
    touch $okayPgDb",
    creates => "$okayPgDb",
    require => Exec["$okayConfig"],
    notify => Service['postgresql-8.4'],
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    cwd => '/opt', # must have read access to it 
  }
  
  service {'postgresql-8.4':
    ensure => running,
    require =>  [ File['/run/postgresql'], Exec [ "$okayConfig"], ],
    } 
}

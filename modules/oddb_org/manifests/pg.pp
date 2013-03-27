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
  
  $pg_oddb_db_load_script = "/usr/local/bin/pg_create_db.sh"
  file { "$pg_oddb_db_load_script":
    content => template("oddb_org/pg_create_db.sh.erb"),
    owner => 'postgres',
    group => 'postgres',
    mode  => 0554,
    require => [Package['apache', 'postgresql-server'], ],
    notify => Service['postgresql-8.4'],
  }
  
  file{'/run/postgresql': # TODO: Not sure whether this is managed correctly by funtoo.
    ensure => directory,
    owner => 'postgres',
    group => 'postgres',
    mode  => 0777,
    require =>  Package['postgresql-server'],                  
  }
  
  $pg_server_configured = "/opt/pg_server.okay"
  exec{ "$pg_server_configured":
    command => "echo y | emerge --config dev-db/postgresql-server:8.4 && rc-config add postgresql-8.4 default && touch $pg_server_configured",
    creates => "$pg_server_configured",
    require => Package['postgresql-server'],
    notify => Service['postgresql-8.4'],
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
  }
  
  $pg_oddb_loaded = "/opt/pg_oddb_loaded.okay"
  exec{ "run_pg_oddb_loaded":
    command => "$pg_oddb_db_load_script && touch $pg_oddb_loaded",
    creates => "$pg_oddb_loaded",
    require => Service['postgresql-8.4'],
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    timeout => 15*160, # max wait time in seconds, took just above default 5 minutes on my machine
  }
  
  $okayPgCfg= "/opt/pg_create_user.configured"
  exec{ "pg_create_user":
    command => "sudo -u postgres dropdb oddb.org.ruby193; \
    sudo -u postgres psql -c 'drop role oddb;'; \
    sudo -u postgres createdb -E UTF8 -T template0 oddb.org.ruby193 && \
    sudo -u postgres psql -c 'create role oddb;' &&  \
    touch $okayPgCfg",
    creates => "$okayPgCfg",
    require => [Service ['postgresql-8.4'], ],
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    cwd => '/opt', # must have read access to it 
  }
  
  service {'postgresql-8.4':
    ensure => running,
    require =>  [ File['/run/postgresql'],
                  Exec [ "$pg_server_configured"],
                ],
    } 
}

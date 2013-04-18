# Here we define all needed stuff to configure the currency server
# for ODDB.org

class oddb_org::currency(
  $username     = hiera('::oddb_org::username', 'dummy_user'),
  $root_name    = hiera('::oddb_org::root_name', 'dummy_root'),
  $root_pass    = hiera('::oddb_org::root_hash', 'dummy_root_hash'),
) inherits oddb_org {

  $currency_run     = "/var/lib/service/currency/run"
  exec{ "$currency_run":
    command => "$create_service_script $oddb_user currency /usr/local/bin/currencyd",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$currency_run",
    user => 'root', # need to be root to (re-)start yus
  }

  $currency_repo = '/opt/src/ycurrency'
  vcsrepo {  "$currency_repo":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => 'git://scm.ywesee.com/currency',
      # cloning via git did not work!
      # source => "git://scm.ywesee.com/oddb.org/.git ",
      require => [User['apache'],],
  }  
   
  $service_location = "/usr/local/bin/currencyd"
  $service_depend   = ""
  $service_user     = "$oddb_user"
  
  exec{ "$service_location":
    command => "gem install currency",
    path => '/usr/local/bin:/usr/bin:/bin',
    creates => $service_location,
  }
  
  service{"currency":
    ensure => running,
    provider => "daemontools",
#    path     => "/
    hasrestart => true,
    require    => [User['apache'], Exec["$service_location", "$currency_run"], ],
  }

}

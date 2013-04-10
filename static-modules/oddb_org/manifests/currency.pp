# Here we define all needed stuff to configure the currency server
# for ODDB.org

class oddb_org::currency(
  $username     = hiera('::oddb_org::username', 'dummy_user'),
  $root_name    = hiera('::oddb_org::root_name', 'dummy_root'),
  $root_pass    = hiera('::oddb_org::root_hash', 'dummy_root_hash'),
) inherits oddb_org {
  # at the moment we assume it as installed!

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
    command => "gem install ycurrency",
    path => '/usr/local/bin:/usr/bin:/bin',
    creates => $service_location,
  }
  
  $currency_service = '/etc/init.d/currency'
  file{ "$currency_service":
    content => template("oddb_org/service.erb"),
    owner => 'root',
    group => 'root',
    mode  => 0755,
    require => Exec["$service_location"],
  }
  
  service{"currency":
    ensure => running,
    hasrestart => true,
    require    => [User['apache'], File["$currency_service"]],
    subscribe  => File["$currency_service"],
  }
}

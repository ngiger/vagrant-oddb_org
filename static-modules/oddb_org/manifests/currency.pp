# Here we define all needed stuff to configure the currency server
# for ODDB.org

class oddb_org::currency(
  $username     = hiera('::oddb_org::username', 'dummy_user'),
  $root_name    = hiera('::oddb_org::root_name', 'dummy_root'),
  $root_pass    = hiera('::oddb_org::root_hash', 'dummy_root_hash'),
  $bundle_currency =  "$inst_logs/bundle_currency_install.okay"
) inherits oddb_org {

  $currency_repo = '/opt/src/ycurrency'
  exec { "$bundle_currency":
    command => "eselect ruby set ruby19 && git pull && touch $bundle_currency",
    creates => "$bundle_currency",
    cwd => "$currency_repo",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [  Package['bundler'] ,
        Vcsrepo[$currency_repo],    
    ],
  }

  vcsrepo {  "$currency_repo":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => 'https://github.com/zdavatz/currency.git',
      require => [User['apache'],],
  }  
   
  oddb_org::add_service{"currency":
    working_dir => "$currency_repo",
    user        => "$oddb_user",
    exec        => '/usr/local/bin/ruby',
    arguments   => 'bin/currencyd',
    require     => [Vcsrepo["$currency_repo"], User['apache'], Exec["$bundle_currency"], ],
  }
}

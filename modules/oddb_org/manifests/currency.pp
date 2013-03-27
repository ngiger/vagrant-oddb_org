# Here we define all needed stuff to configure the currency server
# for ODDB.org

class oddb_org::currency(
  $username = 'niklaus',
  $root_name = "niklaus@ywesee.com",
  $root_pass = "ec74c79bb6e82b4a0a448f6a1134d8fd4fd3c6ff40fd7ec58adee9805c757c24",
  $currency_ruby_version = '1.8.7_p371'
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
      # TODO: require => [User['apache'],],
  }  
   
  $currency_installed = "/usr/local/bin/currencyd"
  exec{ "$currency_installed":
    command => "gem install ycurrency",
    path => '/usr/local/bin:/usr/bin:/bin',
    creates => $currency_installed,
  }
    
}

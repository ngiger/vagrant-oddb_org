# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }

class oddb_org::oddb_git inherits oddb_org {
  $oddbRoot = '/var/www/oddb.org'
  
  if !defined(User['apache']) {
    user{'apache': require => Package['apache']}
  }
  if !defined(Group['apache']) {
    group{'apache': require => Package['apache']}
  }
  vcsrepo {  "$oddbRoot":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => "git://scm.ywesee.com/oddb.org/.git ",
      require => [User['apache'],],
  }  
}

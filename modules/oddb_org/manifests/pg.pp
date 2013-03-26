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
  
  package {'postgresql-base':
    ensure => '8.4.9',
    }  
        
  package {'postgresql-server':
    ensure => '8.4.9',
    }  
        
}

# Here we define all needed stuff to configure the apache server
# for ODDB.org

class oddb_org::apache inherits oddb_org {

  # we need an apache installation
  #  class {'apache':  } # puppetlabs-apache does not work on gentoo
    package{'apache': }
    service{'apache2':
      ensure => running,
  }   
  
  file { "/etc/apache2/httpd.conf":
    source => "puppet:///modules/oddb_org/httpd.conf.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  # TODO: fix /usr/local/lib64/ruby/gems/1.9.1/gems/sbsm-1.0.7/lib
  # 02_oddb_vhost.conf.txt for Ruby 1.9.3 without Rockit 
  file { "/etc/apache2/vhosts.d/oddb.conf":
    source => "puppet:///modules/oddb_org/02_oddb_vhost.conf.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  file { "/etc/apache2/modules.d/90_mod_ruby.conf":
    source => "puppet:///modules/oddb_org/21_mod_ruby.conf.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  

}

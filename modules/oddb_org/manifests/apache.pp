# Here we define all needed stuff to configure the apache server
# for ODDB.org

class oddb_org::apache inherits oddb_org {

  # we need an apache installation
  #  class {'apache':  } # puppetlabs-apache does not work on gentoo
#    package{'apache': }
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
  
  file { "/etc/apache2/modules.d/21_mod_ruby.conf":
    source => "puppet:///modules/oddb_org/21_mod_ruby.conf",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  
 file { "/var/www/localhost/htdocs/index.html":
    content => " <html><body><h1>It works. Serving localhost (not oddb.org)!</h1></body></html>",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
 file { "/var/www/oddb.org/index.html":
    content => " <html><body><h1>It works. Serving from /var/www/oddb.org !</h1></body></html>",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
   
   
  $mod_ruby_git = '/opt/src/mod_ruby'
  vcsrepo {  "$mod_ruby_git":
      ensure => present,
      provider => git,
      owner => 'apache',
      group => 'apache',
      source => 'https://github.com/shugo/mod_ruby.git',
      # cloning via git did not work!
      # source => "git://scm.ywesee.com/oddb.org/.git ",
#      require => [User['apache'],],
  }  
  $install_mod_ruby_script = '/usr/local/bin/install_mod_ruby.sh'
  file { "$install_mod_ruby_script":
    source => "puppet:///modules/oddb_org/install_mod_ruby.sh",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
 
  $install_mod_ruby = '/opt/mod_ruby.okay'
  exec{"$install_mod_ruby":
    command => "sudo -i $install_mod_ruby_script && \
    touch $install_mod_ruby",
    creates => "$install_mod_ruby",
    path => '/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin',
    require => File["$install_mod_ruby_script"],
   }
   
   # TODO: Added to /etc/hosts
   # 10.0.2.15       oddb.niklaus.org
   # changed in /etc/apache2/vhosts.d/oddb
   # oddb.zeno.org -> oddb.niklaus.org
}

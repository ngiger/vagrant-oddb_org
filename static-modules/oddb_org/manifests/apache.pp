# Here we define all needed stuff to configure the apache server
# for ODDB.org

class oddb_org::apache(
) inherits oddb_org {
  include oddb_org::oddb_git

  # we need an apache installation
  #  class {'apache':  } # puppetlabs-apache does not work on gentoo
    service{'apache2':
      ensure => running,
      require => [ Package['apache'], ],
  }   
  
  file { "/etc/apache2/httpd.conf":
    source => "puppet:///modules/oddb_org/httpd.conf.txt",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
      require => [ Package['apache'], ],
  }
  
  package{ 'sbsm':  provider => gem, }
  
  # TODO: fix /usr/local/lib64/ruby/gems/1.9.1/gems/sbsm-1.0.7/lib
  # 02_oddb_vhost.conf.txt for Ruby 1.9.3 without Rockit 
  file { "/etc/apache2/vhosts.d/oddb.conf":
    content => template("oddb_org/oddb_vhost.conf.erb"),
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache', 'sbsm'], ],
    notify => Service['apache2'],
  }
  
  file { "/etc/apache2/modules.d/21_mod_ruby.conf":
    source => "puppet:///modules/oddb_org/21_mod_ruby.conf",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  
  
 file { "/var/www/localhost/htdocs/index.html":
    content => " <html><body><h1>It works. Serving localhost (not server ${::oddb_org::server_name})!</h1></body></html>",
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
    require => [Package['apache'], Vcsrepo["$oddb_org::oddb_git::ODDB_HOME"], ],
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
      require => [User['apache'],],
  }  
  
  $install_mod_ruby_script = '/usr/local/bin/install_mod_ruby.sh'
  file { "$install_mod_ruby_script":
    source => "puppet:///modules/oddb_org/install_mod_ruby.sh",
    owner => 'apache',
    group => 'apache',
    mode  => 0554,
    require => [Package['apache'], ],
  }
  $install_mod_ruby = "$inst_logs/mod_ruby.okay"
  exec{"$install_mod_ruby":
    command => "sudo -i $install_mod_ruby_script && \
    touch $install_mod_ruby",
    path => "$path",
    require => File["$install_mod_ruby_script"],
    onlyif  => "/usr/bin/diff /opt/src/mod_ruby/mod_ruby.so /usr/lib64/apache2/modules/mod_ruby.so; /usr/bin/test $? -ne 0",
   }
   
  $apache2_conf = '/etc/conf.d/apache2'
  $key          = 'APACHE2_OPTS'
  $value        = '-D RUBY -D DEFAULT_VHOST -D INFO -D SSL -D SSL_DEFAULT_VHOST -D LANGUAGE'
  
  file {"$apache2_conf":
    content => "#managed by puppet oddb_org/manifests/apache.pp
$key=\"$value\"
",
      owner => 'root',
      group => 'root',
      mode => 0644,
  }
  
}

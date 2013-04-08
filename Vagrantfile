# see http://vagrantup.com
# Copyright (c) Niklaus Giger, <niklaus.giger@member.fsf.org>
# License: GPLv2
# Boxes are stored under ~/.vagrant.d/boxes/

#boxUrl = 'http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/vagrant/x86-64bit/vagrant-generic_64-funtoo-current-2012-01-26.box'
boxName     = 'funtoo-oddb'
require 'yaml'
hieraCfg = YAML.load(File.open( 'hieradata/private/config.yaml' ) )

Vagrant::Config.run do |config|
  # Setup the box
  config.vm.box = boxName
  config.vm.box_url = boxUrl if defined?(boxUrl)
  
  # Boot with a GUI so you can see the screen. (Default is headless)
  config.vm.boot_mode = :gui
  config.vm.provision :puppet, :options => "--debug"
  
  config.vm.provision :puppet do |puppet|
    # This shell provisioner installs librarian-puppet and runs it to install
    # puppet modules. This has to be done before the puppet provisioning so that
    # the modules are available when puppet tries to parse its manifests.
    config.vm.provision :shell, :path => "shell/main.sh"
    
    # Now run the puppet provisioner. Note that the modules directory is entirely
    # managed by librarian-puppet
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.module_path    = "modules"
  end
  
  if false
    # I cannot use the following three lines as specified by https://github.com/gposton/vagrant-hieradata
    # because this lead to trying to install apt usinge puppetlabs repository  
    #  config.hiera.config_path = File.join(Dir.pwd, 'hieradata')
    #  config.hiera.config_file = 'hiera.yaml'
    #  config.hiera.data_path   = File.join(Dir.pwd, 'hieradata')
  else # use my workaround
    config.vm.share_folder "hieradata", "/etc/puppet/hieradata", File.join(Dir.pwd, 'hieradata')
  end
  

  # cannot specify an ip. Only works with the default of 10.0.2.15 of vagrant
  #  config.vm.network :hostonly, hieraCfg['::oddb_org::ip']
  config.vm.host_name     = hieraCfg['::oddb_org::hostname']
  config.vm.forward_port   22, 55022    # ssh
  config.vm.forward_port   80, 55080    # apache
  
end

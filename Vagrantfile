# see http://vagrantup.com
# Copyright (c) Niklaus Giger, <niklaus.giger@member.fsf.org>
# License: GPLv2
# Boxes are stored under ~/.vagrant.d/boxes/
require 'vagrant-hiera'

boxUrl = 'http://ftp.heanet.ie/mirrors/funtoo/funtoo-current/vagrant/x86-64bit/vagrant-generic_64-funtoo-current-2012-01-26.box'
puts "Using boxUrl #{boxUrl}"

Vagrant::Config.run do |config|
  # Setup the box
  config.vm.provision :puppet, :options => "--verbose"
  config.vm.customize ["modifyvm", :id, "--memory", 3036]    
  config.vm.customize do |vm|
    vm.memory_size  = 2048 # MB
  end
  
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
#    puppet.manifest_file = "minimal.pp"
    puppet.manifest_file = "site.pp"
    puppet.module_path = "modules"
  end

  config.hiera.config_path = '.'
  config.hiera.config_file = 'vagrant_hiera.yaml'
  config.hiera.data_path   = '.'    
  
  config.vm.define :server do |thisbox|  
    thisbox.vm.host_name = "oddb_dev.#{`hostname -d`.chomp}"
    thisbox.vm.network :hostonly, "192.168.50.55"
    thisbox.vm.box     = "oddb.or.devel"
    thisbox.vm.box_url = boxUrl
    thisbox.vm.forward_port   22, 22022    # ssh
    thisbox.vm.forward_port   80, 22080    # apache
  end
  
end

# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
Vagrant.require_plugin 'vagrant-vbox-snapshot'

ForDebian = true

#------------------------------------------------------------------------------------------------------------
# Some simple customization below
#------------------------------------------------------------------------------------------------------------
if ForDebian
	box_name = 'Elexis-Wheezy-amd64-20130510'
	privateDebian = "/opt/src/veewee-elexis/#{box_name}.box"
	box_to_use = File.exists?(privateDebian) ? privateDebian : "http://ngiger.dyndns.org/downloads/#{box_name}.box"
else
	box_name = 'funtoo-oddb-20130617'
	privateFuntoo = "/opt/src/veewee-ngiger/funtoo-oddb-20130617.box"
	box_to_use = File.exists?(privateFuntoo) ? privateFuntoo : "http://ngiger.dyndns.org/downloads/#{box_name}.box"
end

bridgedNetworkAdapter = "eth0" # adapt it to your liking, e.g. on MacOSX it might 
# bridgedNetworkAdapter = "en0: Wi-Fi (AirPort)" # adapt it to your liking, e.g. on MacOSX it might 
hieraCfg = YAML.load(File.open( 'hieradata/private/config.yaml' ) )


#------------------------------------------------------------------------------------------------------------
# End of simple customization
#------------------------------------------------------------------------------------------------------------
# All Vagrant configuration is done here. The most common configuration
# options are documented and commented below. For a complete reference,
# please see the online documentation at vagrantup.com.

# A good solution would be http://oddbfault.com/questions/418422/public-static-ip-for-vagrant-boxes


Vagrant.configure("2") do |config| 

  config.vm.provider :virtualbox do |vb|
    # 6000 break after import_daily FI
    # 9000 break after import_daily PI
    puts "cpus auf 3/ioapc gestell"
    vb.customize ["modifyvm", :id, "--memory", 10000 ]
    vb.customize ["modifyvm", :id, "--cpus", "3"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.gui = true
  end

  # This shell provisioner installs librarian-puppet and runs it to install
  # puppet modules. This has to be done before the puppet provisioning so that
  # the modules are available when puppet tries to parse its manifests.
  config.vm.provision :shell, :path => ForDebian ? "shell/main_debian.sh" : "shell/main_funtoo.sh"
  config.vm.provision :puppet do |puppet|    
    # Now run the puppet provisioner. Note that the modules directory is entirely
    # managed by librarian-puppet
    puppet.options        = '--debug'
    puppet.hiera_config_path = File.join(File.dirname(__FILE__), 'hieradata', 'hiera.yaml')
    puppet.working_directory = '/vagrant'
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "site.pp"
    puppet.module_path    = "modules"
  end
  
  config.vm.define :oddb do |oddb|  
    portBase ||= hieraCfg['::vagrant::portBase'] 
    portBase ||= 44000
    oddb.vm.box     = box_name
    oddb.vm.box_url = box_to_use
    oddb.vm.provider :virtualbox do |vb| vb.name    = "oddb_#{portBase/1000}_funtoo" end
    puts "Using box_to_use #{box_to_use}"
    oddb.vm.hostname = "oddb.#{`hostname -d`.chomp}"
    puts oddb.vm.hostname

    privateIp = hieraCfg['::oddb_org::ip']
    privateIp ||= "192.168.50.#{portBase/1000}"
    unless /\.#{portBase/1000}$/i.match(privateIp)
      puts "portBase #{portBase/1000} should be last digits of ::oddb_org::ip in config.yaml but is #{privateIp}"
      
      exit
    end
    puts "IP ist " + privateIp
   
    oddb.vm.network :private_network, ip: privateIp 
    oddb.vm.network :forwarded_port, guest: 22, host: portBase + 22  # ssh
    oddb.vm.network :forwarded_port, guest: 80, host: portBase + 80  # apache
		oddb.vm.synced_folder File.join(File.dirname(__FILE__), 'hieradata'), "/etc/puppet/hieradata"
	end
  
end

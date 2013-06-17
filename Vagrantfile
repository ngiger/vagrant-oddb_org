# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

#------------------------------------------------------------------------------------------------------------
# Some simple customization below
#------------------------------------------------------------------------------------------------------------
funtooName = 'funtoo-oddb-20130617'
privateFuntoo = "/opt/src/veewee-ngiger/funtoo-oddb-20130617.box"
funtooBox = File.exists?(privateFuntoo) ? privateFuntoo : "http://ngiger.dyndns.org/downloads/#{funtooName}.box"

debianName = 'Elexis-Wheezy-amd64-20130510'
privateDebian = "/opt/src/veewee-elexis/#{debianName}.box"
debianBox = File.exists?(privateDebian) ? privateDebian : "http://ngiger.dyndns.org/downloads/#{debianName}.box"


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
    vb.customize ["modifyvm", :id, "--memory", 6200, "--cpus", 2,  ]
    vb.gui = true
  end

  # This shell provisioner installs librarian-puppet and runs it to install
  # puppet modules. This has to be done before the puppet provisioning so that
  # the modules are available when puppet tries to parse its manifests.
  config.vm.provision :shell, :path => "shell/main.sh"
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
  
  config.vm.define :oddbFuntoo do |oddbFuntoo|  
    oddbFuntoo.vm.box     = funtooName
    oddbFuntoo.vm.box_url = funtooBox
    oddbFuntoo.vm.provider :virtualbox do |vb| vb.name    = "oddb_funtoo" end
    puts "Using funtooBox #{funtooBox}"
    oddbFuntoo.vm.hostname = "oddb.#{`hostname -d`.chomp}"

    portBase ||= hieraCfg['::vagrant::portBase'] 
    portBase ||= 44000
    privateIp = hieraCfg['::oddb_org::ip']
    privateIp ||= "192.168.50.#{portBase/1000}"
    oddbFuntoo.vm.network :private_network, ip: privateIp 
    oddbFuntoo.vm.network :forwarded_port, guest: 22, host: portBase + 22  # ssh
    oddbFuntoo.vm.network :forwarded_port, guest: 80, host: portBase + 80  # apache
    if false
      # I cannot use the following three lines as specified by https://github.com/gposton/vagrant-hieradata
      # because this lead to trying to install apt usinge puppetlabs repository  
      #  config.hiera.config_path = File.join(Dir.pwd, 'hieradata')
      #  config.hiera.config_file = 'hiera.yaml'
      #  config.hiera.data_path   = File.join(Dir.pwd, 'hieradata')
    else # use my workaround
      # config.vm.synced_folder "src/", "/srv/website"
      # config.vm.synced_folder "/etc/puppet/hieradata", File.join(File.dirname(__FILE__), 'hieradata') , disabled: true
      oddbFuntoo.vm.synced_folder File.join(File.dirname(__FILE__), 'hieradata'), "/etc/puppet/hieradata"
    end    
  end
  
end

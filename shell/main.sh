#!/bin/sh
# from https://github.com/purple52/librarian-puppet-vagrant
logger "Running shell/main.sh"

# Directory in which librarian-puppet should manage its modules directory
if [ -d /vagrant ] ; then PUPPET_DIR=/vagrant ; else PUPPET_DIR=/etc/puppet ; fi

# NB: librarian-puppet might need git installed. If it is not already installed
# in your basebox, this will manually install it at this point using apt or yum
GIT=/usr/bin/git
APT_GET=/usr/bin/apt-get
YUM=/usr/sbin/yum
if [ ! -x $GIT ]; then
    if [ -x $YUM ]; then
        yum -q -y makecache
        yum -q -y install git
    elif [ -x $APT_GET ]; then
        apt-get -q -y update
        apt-get -q -y install git
    else
        echo "No package installer available. You may need to install git manually."
    fi
fi
emerge --sync && etc-update --automode -5

if [ ! -f /etc/hiera.yaml ]; then ln -s /etc/puppet/hieradata/hiera.yaml /etc/hiera.yaml; fi

# eix and ruby-augeas must also be installed before running puppet 
which eix 
if [ $? -ne 0 ] ; then emerge eix ; fi
eix ruby-augeas | grep Installed
if [ $? -ne 0 ] ; then emerge ruby-augeas ; fi
gem list librarian-puppet | grep librarian-puppet
if [ $? -ne 0 ] ; then gem install librarian-puppet --no-ri --no-rdoc ; fi


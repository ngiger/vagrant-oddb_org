#!/bin/sh
# from https://github.com/purple52/librarian-puppet-vagrant

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

if [ ! -d /vagrant ] ; then cp /vagrant/Puppetfile $PUPPET_DIR ; fi

if [ "$(gem search -i librarian-puppet)" = "false" ]; then
  gem install --no-ri --no-rdoc librarian-puppet
  cd $PUPPET_DIR && librarian-puppet install --clean
else
  cd $PUPPET_DIR && librarian-puppet update
fi

grep 10.0.2.15 /etc/hosts
if [ $? -ne 0 ]
then
  echo 10.0.2.15 oddb.niklaus.org oddb >> /etc/hosts
fi

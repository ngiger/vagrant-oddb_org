#!/bin/bash -v
eselect ruby set ruby19
export BINDIR="/usr/local/ruby19/bin"
# emerge ruby-termios
#export RUBYOPT="-rauto_gem"
export DEST=/usr/local/src/yus19
# We want to ensure that the following three gems are installed via emerge for $gem_1_8
gem19 install --no-ri --no-rdoc bundler
if [ -d $DEST ] ; then
  cd $DEST
  git checkout .
  git pull
else
  mkdir -p `dirname $DEST`
  git clone https://github.com/ngiger/yus.git $DEST
  cd $DEST
fi
git checkout without_needle
BUNDLE_SYSTEM_BINDIR=${BINDIR}/bin sudo -u apache bundle install 2>&1 | tee /opt/yus_installed_ruby19.log

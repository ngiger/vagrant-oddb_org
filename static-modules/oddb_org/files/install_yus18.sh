#!/bin/bash -v
eselect ruby set ruby18
emerge ruby-termios
export BINDIR="/usr/local/ruby18/bin"
export RUBYOPT="-rauto_gem"
export DEST=/usr/local/src/yus18
# We want to ensure that the following three gems are installed via emerge for $gem_1_8
gem18 install --no-ri --no-rdoc bundler --bindir=$BINDIR
mkdir -p `dirname $DEST` $BINDIR `dirname $DEST`
git clone https://github.com/zdavatz/yus.git $DEST
cd $DEST
BUNDLE_SYSTEM_BINDIR=${BINDIR}/bin sudo -u apache ruby18 ${BINDIR}/bundle install --without test development 2>&1 | tee /opt/yus_installed_ruby18.log

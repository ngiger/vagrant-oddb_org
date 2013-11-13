#!/bin/bash -v
eselect ruby set ruby18
emerge ruby-termios
export BINDIR="/usr/local/ruby18/bin"
export RUBYOPT="-rauto_gem"
export DEST=/usr/local/src/yus
# We want to ensure that the following three gems are installed via emerge for $gem_1_8
gem18 install --no-ri --no-rdoc bundler --bindir=$BINDIR
mkdir -p `dirname $DEST` $BINDIR `dirname $DEST`
git clone https://github.com/zdavatz/yus.git $DEST
cd $DEST
BUNDLE_SYSTEM_BINDIR=${BINDIR}/bin ${BINDIR}/bundle install --without test development 2>&1 | tee /opt/yus_installed_ruby18.log
eselect ruby set ruby19
gem install bundler 
bundle install --without test development 2>&1 | tee /opt/yus_installed_ruby19.log
head /usr/local/bin/yus*  ${BINDIR}/yus* | grep bin >/opt/yus_installed.log

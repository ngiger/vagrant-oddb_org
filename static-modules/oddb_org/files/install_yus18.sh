#!/bin/bash -v
export BINDIR="/usr/local/ruby18/bin"
export RUBYOPT="-rauto_gem"
eselect ruby set ruby18
emerge ruby-termios
export DEST=/usr/local/src/yus18
# We want to ensure that the following three gems are installed via emerge for $gem_1_8
gem18 install --no-ri --no-rdoc bundler --bindir=$BINDIR
mkdir -p `dirname $DEST` $BINDIR `dirname $DEST`
git clone https://github.com/zdavatz/yus.git $DEST
cd $DEST
BUNDLE_SYSTEM_BINDIR=${BINDIR}/bin sudo -u apache ruby18 ${BINDIR}/bundle install --without test development 2>&1 | tee /opt/yus_installed_ruby18.log

# equery list ruby

#  * Searching for ruby ...
# [I--] [??] dev-lang/ruby-1.8.7_p374-r1:1.8
# [IP-] [  ] dev-lang/ruby-1.9.3_p547:1.9
# [IP-] [  ] dev-lang/ruby-2.0.0_p481:2.0
# [IP-] [  ] dev-lang/ruby-2.1.2:2.1
# 
# ch.oddb> registration('61249').sequence('01').packages.first
# -> ["001", #<ODBA::Stub:70132763856000#31915772 @odba_class=ODDB::Package @odba_container=70132764015480#31915762>]
# ch.oddb> registration('61249').sequence('02').packages.first
# -> ["002", #<ODBA::Stub:77163000#31915784       @odba_class=ODDB::Package @odba_container=77042460#31915778>]
# sudo emerge "=dev-lang/ruby-1.9.3_p547"
# sudo emerge "=dev-lang/ruby-1.8.7_p374-r1"
# http://en.wikipedia.org/wiki/Rack_%28web_server_interface%29
# http://code.macournoyer.com/thin/
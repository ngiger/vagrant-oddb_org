#!/bin/bash -v
eselect ruby set ruby18
export RUBYOPT="-rauto_gem"
# We want to ensure that the following three gems are installed via emerge for gem18
gem18 uninstall -x --all dbi dbd-pg pg 
gem18 install --no-ri --no-rdoc deprecated --version=2.0.1
gem18 install --no-ri --no-rdoc yus rclconf odba needle ruby-password
emerge =dev-ruby/dbi-0.4.3 =dev-ruby/dbd-pg-0.3.9 =dev-ruby/pg-0.13.2
gem18 list --local
head /usr/local/bin/yus* | grep bin >/opt/yus_installed_before_eselect.log
eselect ruby set ruby19
gem19 uninstall -x yus
gem18 install yus
head /usr/local/bin/yus* | grep bin >/opt/yus_installed.log

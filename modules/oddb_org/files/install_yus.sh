#!/bin/bash -v
export PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin
ruby -v
emerge ruby-password dev-ruby/dbi dev-ruby/dbd-pg
gem install --no-ri --no-rdoc yus rclconf odba needle pg 
gem install --no-ri --no-rdoc deprecated --version=0.2.1
gem list --local

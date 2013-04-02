#!/bin/bash -v
export RUBYOPT="-rauto_gem"
gem18 install --no-ri --no-rdoc deprecated --version=2.0.1
gem18 install --no-ri --no-rdoc yus rclconf odba needle
emerge =dev-ruby/dbi-0.4.3 =dev-ruby/dbd-pg-0.3.9 =dev-ruby/pg-0.11.0
gem18 list --local

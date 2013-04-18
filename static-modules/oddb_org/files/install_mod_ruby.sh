#!/bin/bash -v
cd /opt/src/mod_ruby
./configure.rb --with-apxs --with-apr-includes=/usr/include/apr-1
make && make install 

rvm use 1.9.3
cd /opt/src/mod_ruby
./configure.rb --with-apxs --with-apr-includes=/usr/include/apr-1
make && make install 
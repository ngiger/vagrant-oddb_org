eselect ruby set ruby19
# we emerge mod_ruby to ensure that we will be able to compile our own version
emerge mod_ruby
cd /opt/src/mod_ruby
./configure.rb --with-apxs --with-apr-includes=/usr/include/apr-1
make && make install 

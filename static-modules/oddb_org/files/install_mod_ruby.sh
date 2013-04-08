eselect ruby set ruby19
cd /opt/src/mod_ruby
./configure.rb --with-apxs --with-apr-includes=/usr/include/apr-1
make && make install 
emerge --unmerge mod_ruby
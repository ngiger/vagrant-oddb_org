#!/bin/bash -v
cd <%= ODDB_HOME %>
pwd
git clone ssh://ywesee@scm.ywesee.com/home/ywesee/git/oddb.org
cd oddb.org/data
mkdir pdf
cd quanty
pwd
ruby18 extconf.rb
make
make install
cd ../..
cp .git/refs/heads/master .git/ORIG_HEAD
cp <%= $SETUP_DIR %>/db_connection.rb etc/
cp <%= $SETUP_DIR %>/robots-disallow.txt doc/
cp -r <%= $SETUP_DIR %>/captcha data
ruby bin/update_css
cp <%= $SETUP_DIR %>/dojo-release-1.3.0.tar.gz doc/resources
cd doc/resources
tar zxvf dojo-release-1.3.0.tar.gz
mv dojo-release-1.3.0 dojo
cp <%= $SETUP_DIR %>/oddb.yml ../../etc/
scp -r ywesee@thinpower.ywesee.com:/var/www/oddb.org/doc/resources/sponsor .
# for local jobs import/export scripts
cp <%= $SETUP_DIR %>/testenvironment.rb ../../src/
cp <%= $SETUP_DIR %>/testenvironment2.rb ../../src/
cp <%= $SETUP_DIR %>/gitignore ../../.gitignore

#!/bin/bash -v
#helper script to get the images from the real server

sudo -u apache scp -r niklaus@172.25.1.233:/opt/downloads/images /var/www/oddb.org/doc/resources/
sudo -u apache scp -r niklaus@172.25.1.233:/opt/downloads/rss /var/www/oddb.org/data

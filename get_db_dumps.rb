#!/usr/bin/env ruby
# Utility scripts to download the needed db files for vagrant 
# They will be stored in the subdirectory db_dumps

require 'fileutils'

yesterday = Time.now-24*60*60

Dest = File.expand_path(File.join(File.dirname(__FILE__), 'db_dumps'))
FileUtils.makedirs(Dest)

Databases = ['oddb.org.ruby193', 'migel']

Databases.each{
  |db_name|
    yyyy = yesterday.strftime('%Y')
    mm = yesterday.strftime('%m')
    month = yesterday.strftime('%B')
    dd = yesterday.strftime('%d')
    dest_file = "#{Dest}/pg-db-#{db_name}-backup.gz"
    cmd = "scp  ywesee@thinpower.ywesee.com:/var/backup/thinpower/db/postgresql/#{month}-#{yyyy}/#{yyyy}-#{mm}-#{dd}/22\:00-postgresql_database-#{db_name}-backup.gz #{dest_file}"
    if File.exists?(dest_file)
      puts "Skipping, as #{dest_file} already exists"
    else
      puts cmd
      exit 1 unless system(cmd)
    end
}

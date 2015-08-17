#!/usr/bin/env ruby
# Utility scripts to download the needed db files for vagrant 
# They will be stored in the subdirectory db_dumps

require 'fileutils'

yesterday = Time.now-24*60*60

Dest = File.expand_path(File.join(File.dirname(__FILE__), '../oddb.org-db_dumps'))
FileUtils.makedirs(Dest)

Databases = ['yus', 'oddb.org.ruby193', 'migel']

Databases.each{
  |db_name|
    yyyy = yesterday.strftime('%Y')
    mm = yesterday.strftime('%m')
    month = yesterday.strftime('%B')
    dd = yesterday.strftime('%d')
    dated_file = "#{Dest}/#{db_name}-#{yyyy}-#{mm}-#{dd}-backup.gz"
    dest_file = "#{Dest}/pg-db-#{db_name}-backup.gz"
    yesterday_file = "#{yyyy}-#{mm}-#{dd}/22\:00-postgresql_database-#{db_name}-backup.gz"
    cmd = "scp  ywesee@thinpower.ywesee.com:/var/backup/thinpower/db/postgresql/#{month}-#{yyyy}/#{yesterday_file} #{dated_file}"
    if File.exists?(dated_file)
      puts "Skipping, as #{dest_file} already exists"
    else
      puts cmd
      FileUtils.rm_f(dated_file, :verbose => true)
      FileUtils.rm_f(dest_file, :verbose => true)
      exit 1 unless system(cmd)
      Dir.chdir(Dest)
      FileUtils.ln_s(File.basename(dated_file), File.basename(dest_file))
    end
}

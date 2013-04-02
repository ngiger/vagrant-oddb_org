#!/usr/bin/env ruby
puts "I am running ruby #{RUBY_VERSION}"
require 'dbi'

begin
  print "Available drivers="
  p DBI.available_drivers

   # connection to database
   dbh = DBI.connect("dbi:pg:testdb:localhost", "masa", "")
   # get server version string
   row = dbh.select_one("select version()")
   puts "Server version: " + row[0]
rescue DBI::DatabaseError => e
   puts "An error occurred"
   puts "Error code: #{e.err}"
   puts "Error message: #{e.errstr}"
ensure
   # disconnect
   dbh.disconnect if dbh
end

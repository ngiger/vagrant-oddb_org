#!/usr/bin/env ruby
unless ARGV.size == 3
  puts "#{__FILE__} must be invoked with three params: ruby_version file_to_patch path_to_patch_file"
  exit 1
end

require 'pp'

ruby_version = ARGV[0]
file_to_patch = ARGV[1]
path_to_patch_file = ARGV[2]
unless File.file?(path_to_patch_file)
  puts "#{path_to_patch_file} does not exists or is not a regular file"
  exit 1
end

candidates = `locate #{file_to_patch} | grep #{ruby_version} | grep -v /src/`.split("\n")
unless candidates.size == 1
  puts "Please specify a better pattern. We should find exactly one file, but found "
  pp candidates[0..3]
  exit 1
end

cmd = "patch -p1 #{candidates[0]} < #{path_to_patch_file}"
system(cmd) ? exit(0) : exit(1)


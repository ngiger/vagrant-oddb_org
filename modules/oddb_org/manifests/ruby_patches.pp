# Here we patch the needed ruby files

class oddb_org::ruby_patches inherits oddb_org::oddb_git {
  
  $csv_patched = "/opt/csv_rb_patched.okay"
  $apply_ruby_patch = "/usr/local/bin/apply_ruby_patch.rb"
  
  file{"$apply_ruby_patch":
    source => "puppet:///modules/oddb_org/apply_ruby_patch.rb",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  
  $csv_rb_patch = "/usr/local/share/cvs.rb.patch"
  file{"$csv_rb_patch":
    source => "puppet:///modules/oddb_org/csv.rb.patch.20111123.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  
  exec{ "$csv_patched":
    command => "$apply_ruby_patch $ruby_version csv.rb $csv_rb_patch && touch $csv_patched",
    creates => "$csv_patched",
    require => Exec [ 'bundle_oddb_org'],
    path => '/usr/local/bin:/usr/bin:/bin',
  }
  
}

# Here we patch the needed ruby files

class oddb_org::ruby_patches inherits oddb_org::oddb_git {
  
  $csv_patched = "$inst_logs/csv_rb_patched.okay"
  $apply_ruby_patch = "/usr/local/bin/apply_ruby_patch.rb"
  
  file{"$apply_ruby_patch":
    source => "puppet:///modules/oddb_org/apply_ruby_patch.rb",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  
  $locate_installed_and_init = "$inst_logs/locate_installed_and_init.okay"
  exec{"$locate_installed_and_init":
    creates => "$locate_installed_and_init",
    command => "emerge mlocate && updatedb && touch $locate_installed_and_init",
    user => 'root',
    path => "$path",
  }
  
  $csv_rb_patch = "/usr/local/share/csv.rb.patch"
  file{"$csv_rb_patch":
    source => "puppet:///modules/oddb_org/csv.rb.patch.20111123.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  
  exec{ "$csv_patched":
    command => "$apply_ruby_patch 1.9 csv.rb $csv_rb_patch && touch $csv_patched",
    creates => "$csv_patched",
    require => [ Exec [ "$oddb_org::oddb_git::bundle_oddb_org", "$locate_installed_and_init" ], File["$apply_ruby_patch"], ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }

  $notification_patched = "$inst_logs/notification_rb_patched.okay"
  $notification_rb_patch = "/usr/local/share/notification.rb.patch"
  file{"$notification_rb_patch":
    source => "puppet:///modules/oddb_org/notification.rb.patch.20130419.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  exec{ "$notification_patched":
    command => "$apply_ruby_patch 1.9 lib/notification.rb $notification_rb_patch && touch $notification_patched",
    creates => "$notification_patched",
    require => [ Exec [ "$oddb_org::oddb_git::bundle_oddb_org", "$locate_installed_and_init" ], File["$apply_ruby_patch"], ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }
  
}

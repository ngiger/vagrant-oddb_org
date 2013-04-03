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
  
  $locate_installed_and_init = '/opt/locate_installed_and_init.okay'
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
    require => Exec [ 'bundle_oddb_org', "$locate_installed_and_init" ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }

  $columninfo_patched = "/opt/columninfo_rb_patched.okay"
  $columninfo_rb_patch = "/usr/local/share/columninfo.rb.patch"
  file{"$columninfo_rb_patch":
    source => "puppet:///modules/oddb_org/columninfo.rb.patch.20111123.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  exec{ "$columninfo_patched":
    command => "$apply_ruby_patch 1.9 lib/dbi/columninfo.rb $columninfo_rb_patch && touch $columninfo_patched",
    creates => "$columninfo_patched",
    require => Exec [ 'bundle_oddb_org', "$locate_installed_and_init" ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }

  $statement_patched = "/opt/statement_rb_patched.okay"
  $statement_rb_patch = "/usr/local/share/statement.rb.patch"
  file{"$statement_rb_patch":
    source => "puppet:///modules/oddb_org/statement.rb.patch.20111125.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  exec{ "$statement_patched":
    command => "$apply_ruby_patch 1.9 lib/dbi/handles/statement.rb $statement_rb_patch && touch $statement_patched",
    creates => "$statement_patched",
    require => Exec [ 'bundle_oddb_org', "$locate_installed_and_init" ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }
  
  $row_patched = "/opt/row_rb_patched.okay"
  $row_rb_patch = "/usr/local/share/row.rb.patch"
  file{"$row_rb_patch":
    source => "puppet:///modules/oddb_org/row.rb.patch.20111125.txt",
    owner => 'root',
    group => 'root',
    mode  => 0755,
  }
  exec{ "$row_patched":
    command => "$apply_ruby_patch 1.9 lib/row.rb $row_rb_patch && touch $row_patched",
    creates => "$row_patched",
    require => Exec [ 'bundle_oddb_org', "$locate_installed_and_init" ],
    path => '/usr/local/bin:/usr/bin:/bin',
  }
  
}

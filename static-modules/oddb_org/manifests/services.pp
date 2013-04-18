# Here we define all needed stuff to configure the services
# for ODDB.org (yus, oddb, currency have separate pp files)

class oddb_org::services(
) inherits oddb_org {

  # not active anymore 
  # * analysisparse
  # * readonly
  # * fipdf
  
  $crawler_name     = "oddb_crawler"
  $crawler_run      = "/var/lib/service/$crawler_name/run"
  exec{ "$crawler_run":
    command => "$create_service_script $oddb_user $crawler_name '$ODDB_HOME/bin/oddbd crawler'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$crawler_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$crawler_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$crawler_run"],
    require    => [User['apache'], Exec["$crawler_run"], ],
  }

  $export_name     = "ch.oddb-export"
  $export_run      = "/var/lib/service/$export_name/run"
  exec{ "$export_run":
    command => "$create_service_script $oddb_user $export_name '$ODDB_HOME/ext/export/bin/exportd'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$export_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$export_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$export_run"],
    require    => [User['apache'], Exec["$export_run"], ],
  }

  $fiparse_name     = "ch.oddb-fiparse"
  $fiparse_run      = "/var/lib/service/$fiparse_name/run"
  package{'app-text/wv2': }
  
  exec{ "$fiparse_run":
    command => "$create_service_script $oddb_user $fiparse_name '$ODDB_HOME/ext/fiparse/bin/fiparsed'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools', 'app-text/wv2'],
    ],
    creates => "$fiparse_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  file {"$ODDB_HOME/ext/fiparse/bin/fiparsed":
    ensure => present,
    mode   => 0755,
    owner  => "$oddb_user",
    group  => "$oddb_group",    
  }
  
  service{"$fiparse_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$fiparse_run"],
    require    => [User['apache'], Exec["$fiparse_run"], ],
  }

  $google_crawler_name     = "oddb_google_crawler"
  $google_crawler_run      = "/var/lib/service/$google_crawler_name/run"
  exec{ "$google_crawler_run":
    command => "$create_service_script $oddb_user $google_crawler_name '$ODDB_HOME/bin/oddbd google_crawler'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$google_crawler_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$google_crawler_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$google_crawler_run"],
    require    => [User['apache'], Exec["$google_crawler_run"], ],
  }
  
  $meddata_name     = "ch.oddb-meddata"
  $meddata_run      = "/var/lib/service/$meddata_name/run"
  exec{ "$meddata_run":
    command => "$create_service_script $oddb_user $meddata_name '$ODDB_HOME/ext/meddata/bin/meddatad'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$meddata_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$meddata_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$meddata_run"],
    require    => [User['apache'], Exec["$meddata_run"], ],
  }

  $swissindex_nonpharma_name     = "ch.oddb-swissindex_nonpharma"
  $swissindex_nonpharma_run      = "/var/lib/service/$swissindex_nonpharma_name/run"
  exec{ "$swissindex_nonpharma_run":
    command => "$create_service_script $oddb_user $swissindex_nonpharma_name '$ODDB_HOME/ext/swissindex/bin/swissindex_nonpharmad'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$swissindex_nonpharma_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$swissindex_nonpharma_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$swissindex_nonpharma_run"],
    require    => [User['apache'], Exec["$swissindex_nonpharma_run"], ],
  }

  $swissindex_pharma_name     = "ch.oddb-swissindex_pharma"
  $swissindex_pharma_run      = "/var/lib/service/$swissindex_pharma_name/run"
  exec{ "$swissindex_pharma_run":
    command => "$create_service_script $oddb_user $swissindex_pharma_name '$ODDB_HOME/ext/swissindex/bin/swissindex_pharmad'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$swissindex_pharma_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$swissindex_pharma_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$swissindex_pharma_run"],
    require    => [User['apache'], Exec["$swissindex_pharma_run"], ],
  }
  
  $swissreg_name     = "ch.oddb-swissreg"
  $swissreg_run      = "/var/lib/service/$swissreg_name/run"
  exec{ "$swissreg_run":
    command => "$create_service_script $oddb_user $swissreg_name '$ODDB_HOME/ext/swissreg/bin/swissregd'",
    path => '/usr/local/bin:/usr/bin:/bin',
    require => [
      File["$create_service_script"],
      User["$oddb_user"],
      Package['daemontools'],
    ],
    creates => "$swissreg_run",
    user => 'root', # need to be root to (re-)start yus
  }
  
  service{"$swissreg_name":
    ensure => running,
    provider => "daemontools",
    hasrestart => true,
    subscribe  => Exec["$swissreg_run"],
    require    => [User['apache'], Exec["$swissreg_run"], ],
  }

}

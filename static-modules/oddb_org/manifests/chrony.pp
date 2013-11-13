# Here we define all needed stuff to configure the chrony server
# for ODDB.org

class oddb_org::chrony(
) inherits oddb_org {

  package{ "chrony":
    ensure => "absent"
    }

    if (false) {
  service{ "chronyd":
    ensure => running,
    require => Package['chrony'],
    }
    }
}

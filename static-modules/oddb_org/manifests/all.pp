# == Class: oddb_org
#
# oddb_org::all is responsible for correctly chaining all ressources
# at the first startup.
# Afterwards all ODDB services should be running find
#
# === Parameters
#
# None
#
# === Authors
#
# Niklaus Giger <niklaus.giger@member.fsf.org>
#
# === Copyright
#
# Copyright 2013 Niklaus Giger <niklaus.giger@member.fsf.org>
#
class oddb_org::all (
) inherits oddb_org{
  
    include oddb_org::apache
    include oddb_org::currency
    include oddb_org::mail
    include oddb_org::oddb_git
    include oddb_org::ruby_patches
    include oddb_org::yus
    
    Exec["$oddb_org::yus::yus_grant_user"] -> Service['apache2']
    Service['currency'] -> Service['yus']
    Service['yus'] -> Service['apache2']
    Service['apache2'] -> Service['oddb']
    File["$oddb_org::mail::oddb_yml"] -> Service['oddb']
}
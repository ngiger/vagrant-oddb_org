notice("Running with site.pp")

class {"oddb_org": }
notice("Running with site.pp after oddb_org")

# include oddb_org
# include oddb_org::all


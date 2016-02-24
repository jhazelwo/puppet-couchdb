# == Class couchbase::install
#
# This class is called from couchbase for install.
#
class couchbase::install {

  package { $::couchbase::package_name:
    ensure => present,
  }
}

# == Class couchbase::params
#
# This class is meant to be called from couchbase.
# It sets variables according to platform.
#
class couchbase::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'couchbase'
      $service_name = 'couchbase'
    }
    'RedHat', 'Amazon': {
      $package_name = 'couchbase'
      $service_name = 'couchbase'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}

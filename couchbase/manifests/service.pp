# == Class couchbase::service
#
# This class is meant to be called from couchbase.
# It ensure the service is running.
#
class couchbase::service {

  service { $::couchbase::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}

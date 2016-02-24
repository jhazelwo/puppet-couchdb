# == Class couchbase::service
#
# This class is meant to be called from couchbase.
# It ensure the service is running.
#
#
class couchbase::service (
  $ensure = $::couchbase::service_ensure,
) {
  $service_name = $::kernel ? {
    'windows' => 'CouchbaseServer',
    'Linux'   => 'couchbase-server',
    default   => fail("[${name}] Unsupported OS!"),
  }
  service { $service_name:
    ensure     => $ensure,
    hasrestart => true,
  }
}

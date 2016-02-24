# Class: couchbase
# ===========================
#
# Full description of class couchbase here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class couchbase (
  $package_name = $::couchbase::params::package_name,
  $service_name = $::couchbase::params::service_name,
) inherits ::couchbase::params {

  # validate parameters here

  class { '::couchbase::install': } ->
  class { '::couchbase::config': } ~>
  class { '::couchbase::service': }

  contain '::couchbase::install'
  contain '::couchbase::config'
}

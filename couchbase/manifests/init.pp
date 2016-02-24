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
#
class couchbase(
  $cluster_ramsize,

  $cluster_username = 'Administrator',
  $cluster_password = 'password',
  $cluster_port = '8091',
  $cluster_host = 'localhost',

  $index_path = '/opt/couchbase/nodeindex/',
  $data_path = '/opt/couchbase/nodedata/',

  $buckets = {},

  $try_sleep = 6,
  $tries = 9,

  $service_ensure = 'running',

  $package_file = undef,
  $package_ensure = 'installed',
  $package_temp_dir = '/tmp/',
  $package_iss_file = 'couchbase400.iss',
  $package_provider = undef,
  $package_install_options = undef,
  $wget_source = undef,

  $file_source_base = 'puppet:///modules/couchbase/',
) {

  $etc_path = $::kernel ? {
    'windows' => 'C:/Program Files/Couchbase/Server/etc/',
    'Linux'   => '/opt/couchbase/etc/',
    default   => fail("[${name}] Unsupported OS!"),
  }

  # install Couchbase
  contain '::couchbase::package'

  # Manage the Couchbase daemon
  contain '::couchbase::service'

  # During CB install run couchbase-cli[.exe] node-init and cluster-init ...
  contain '::couchbase::hostinit'

  # Define order (lol)
  Class['::couchbase::package'] ->
    Class['::couchbase::service'] ->
      Class['::couchbase::hostinit']

  create_resources(::couchbase::bucket, $buckets)

}

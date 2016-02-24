#
# Run node-init and host-init
# Executes during Couchbase installation.
#

class couchbase::hostinit(
  $index_path       = $::couchbase::index_path,
  $data_path        = $::couchbase::data_path,
  $cluster_port     = $::couchbase::cluster_port,
  $cluster_username = $::couchbase::cluster_username,
  $cluster_password = $::couchbase::cluster_password,
  $cluster_ramsize  = $::couchbase::cluster_ramsize,
) {

  couchbase::cli {'node-init':
    parameters => join([
      "--node-init-index-path=\"${index_path}\"",
      "--node-init-data-path=\"${data_path}\"",
    ], ' '),
    exec_title => $title,
    creates    => [$data_path, $index_path],
    notify     => Couchbase::Cli['cluster-init'],
  }

  couchbase::cli {'cluster-init':
    parameters  => join([
      "--cluster-init-port=${cluster_port}",
      "--cluster-init-username=${cluster_username}",
      "--cluster-init-password=${cluster_password}",
      "--cluster-ramsize=${cluster_ramsize}",
    ], ' '),
    exec_title  => 'cluster-init',
    refreshonly => true,
  }

}

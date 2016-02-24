# Execute the Couchbase CLI with given parameters.
#
# This module is called by nearly every single couchbase submodule.
# If you need to run something unique that the Couchbase cli supports
# you can do so with this module.
#

define couchbase::cli (
  $action        = $title,
  $creates       = undef,
  $exec_cwd      = undef,
  $exec_title    = undef,
  $exec_loglevel = 'notice',
  $onlyif        = undef,
  $parameters    = '',
  $refreshonly   = false,
  $returns       = 0,
  $tries         = $::couchbase::tries,
  $try_sleep     = $::couchbase::try_sleep,
  $unless        = undef,
  $cli           = undef,
  $username      = $::couchbase::cluster_username,
  $password      = $::couchbase::cluster_password,
  ) {

  $cluster_host = $::couchbase::cluster_host
  $cluster_port = $::couchbase::cluster_port
  $cluster = "-c ${cluster_host}:${cluster_port}"

  $_exec_title = pick($exec_title, "${title} ${action} ${parameters}")

  $cli_by_kernel = $::kernel ? {
    # Windows path quoting: '"C:\program files\foo\bar.exe" -arg1 -arg2'
    'windows' => '"C:/Program Files/Couchbase/Server/bin/couchbase-cli.exe"',
    'Linux'   => '/opt/couchbase/bin/couchbase-cli',
    default   => fail("[${name}] Unsupported OS!"),
  }
  $_cli = pick($cli, $cli_by_kernel)

  $_exec_cwd = $::kernel ? {
    'windows' => 'C:/Program Files/Couchbase/Server/',
    'Linux'   => '/opt/couchbase/',
    default   => fail("[${name}] Unsupported OS!"),
  }

  if $unless { $_unless = "${_cli} ${unless} ${cluster}" }

  if $onlyif { $_onlyif = "${_cli} ${onlyif} ${cluster}" }

  $command = "${_cli} ${action} ${cluster} ${parameters}"

  exec { $_exec_title:
    command     => $command,
    environment => [
      "CB_REST_USERNAME=${username}",
      "CB_REST_PASSWORD=${password}",
    ],
    cwd         => pick($exec_cwd, $_exec_cwd),
    path        => $::path,
    logoutput   => true,
    loglevel    => $exec_loglevel,
    try_sleep   => $try_sleep,
    tries       => $tries,
    creates     => $creates,
    returns     => $returns,
    refreshonly => $refreshonly,
    unless      => $_unless,
    onlyif      => $_onlyif,
  }

}

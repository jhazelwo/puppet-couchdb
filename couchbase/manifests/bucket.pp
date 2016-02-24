#
# Define a Couchbase Bucket
#
# BUG: if bucket-create fails the statefile will remain and block future
# attempts to create the bucket until the statefile is manually removed.


define couchbase::bucket (
  $flush                = 0,
  $replica              = 0,
  $enable_index_replica = 0,
  $ramsize              = 100,
  $port                 = 11211,
  $type                 = 'couchbase',
  $password             = undef,
  $ensure               = 'present',
  $couchbase_etc        = $::couchbase::etc_path,
  ) {

  $_couchbase_etc = $::kernel ? {
    'windows' => 'C:/Program Files/Couchbase/Server/etc/',
    'Linux'   => '/opt/couchbase/etc/',
    default   => fail("[${name}] Unsupported OS!"),
  }

  if $password { $_password = "--bucket-password=${password}" }
    else { $_password = '' }

  $_bucket = "--bucket=${title}"
  $_port = "--bucket-port=${port}"
  $_ramsize = "--bucket-ramsize=${ramsize}"
  $_replica = "--bucket-replica=${replica}"
  $_flush = "--enable-flush=${flush}"
  $_type = "--bucket-type=${type}"
  $_enable_index_replica = "--enable-index-replica=${enable_index_replica}"

  $create_parameters = join([
    $_bucket,
    $_password,
    $_port,
    $_ramsize,
    $_flush,
    $_replica,
    $_type,
    $_enable_index_replica,
    '--wait',
  ], ' ')

  $edit_parameters = join([
    $_bucket,
    $_port,
    $_ramsize,
    $_flush,
  ], ' ')

  if $ensure == 'absent' {

    couchbase::statefile {"bucket-${title}":
      ensure => absent,
    }
    couchbase::cli {"bucket-delete ${title}":
      action     => 'bucket-delete',
      exec_title => "bucket-delete ${title}",
      parameters => $_bucket,
      onlyif     => "bucket-edit ${_bucket}",
    }

  } else {

    couchbase::statefile {"bucket-${title}":
      content   => $create_parameters,
      require   => Class['::couchbase::service'],
      do_notify => Couchbase::Cli["bucket ${title}"],
    }
    couchbase::cli {"bucket ${title}":
      action      => 'bucket-create',
      parameters  => $create_parameters,
      exec_title  => "bucket ${title}",
      unless      => "bucket-edit ${edit_parameters}",
      refreshonly => true,
    }

  }

}

#
# Store $contents in $basedir/etc/.$title
# If $contents change, notify cli[$title]
#
# This is used to make sure settings are updated on
# the server only if/when they change in hiera/params.
#
# Manually changing or deleted the statefiles will trigger a refresh event.
#
define couchbase::statefile (
  $content    = '',
  $ensure     = 'file',
  $do_notify  = Couchbase::Cli[$title],
  $etc_path   = $::couchbase::etc_path,
  $msg_prefix = undef,
  ) {
  $default_msg_prefix = "# Stafefile for ${title}, do not edit! \n"
  $_prefix = pick($msg_prefix, $default_msg_prefix)

  $_file_path = "${etc_path}.${title}"

  if $ensure == 'absent' {

    file { $title:
      ensure => absent,
      path   => $_file_path,
    }

  } else {

    file { $title:
      ensure    => $ensure,
      path      => $_file_path,
      mode      => '0600',
      content   => "${_prefix} ${content}",
      notify    => $do_notify,
      show_diff => false,
    }

  }

}

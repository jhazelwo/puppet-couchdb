#
#
class couchbase::package(
  $package_file = $::couchbase::package_file,
  $package_provider = $::couchbase::package_provider,
  $tempdir = $::couchbase::package_temp_dir,
  $install_options = $::couchbase::package_install_options,
  $iss_file = $::couchbase::package_iss_file,
  $package_ensure = $::couchbase::package_ensure,
  $file_source_base = $::couchbase::file_source_base,
){

  case $::kernel {
    'windows': {
      $package_name = 'Couchbase Server'
      $_install_options = pick($install_options, ['/s', "-f1${iss_file}"])
      $_package_provider = pick($package_provider, 'windows')
      $_tempdir = pick($tempdir, 'c:/')
      }
    'Linux': {
      $package_name = 'couchbase-server'
      $_install_options = $install_options
      $_package_provider = pick($package_provider, 'rpm')
      $_tempdir = pick($tempdir, '/tmp/')
    }
    default: { fail("[${name}] Unsupported OS!") }
  }

  if $::kernel == 'windows' {
    file { "C:/Windows/${iss_file}":
      ensure => 'file',
      source => "${file_source_base}/${iss_file}",
      before => Package[$package_name],
    }
  }

  file { "${_tempdir}${package_file}":
    ensure => 'file',
    mode   => '0700',
    source => "${file_source_base}/${package_file}",
    before => Package[$package_name],
  }

  package { $package_name:
    ensure          => $package_ensure,
    source          => "${_tempdir}${package_file}",
    install_options => $_install_options,
    provider        => $_package_provider,
  }

}

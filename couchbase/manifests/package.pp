#
class couchbase::package(
  $package_file     = $::couchbase::package_file,
  $package_provider = $::couchbase::package_provider,
  $tempdir          = $::couchbase::package_temp_dir,
  $install_options  = $::couchbase::package_install_options,
  $iss_file         = $::couchbase::package_iss_file,
  $package_ensure   = $::couchbase::package_ensure,
  $file_source_base = $::couchbase::file_source_base,
  $wget_source      = $::couchbase::wget_source,
){
  include '::wget'

  case $::kernel {
    'windows': {
      $package_name = 'Couchbase Server'
      $_install_options = pick($install_options, ['/s', "-f1${iss_file}"])
      $_package_provider = pick($package_provider, 'windows')
      $_tempdir = pick($tempdir, 'c:/')
      $_package_file = pick($package_file, 'couchbase-server-enterprise_4.0.0-windows_amd64.exe') #lint:ignore:80chars
      $_wget_source = pick($wget_source, 'http://packages.couchbase.com/releases/4.0.0/couchbase-server-enterprise_4.0.0-windows_amd64.exe') #lint:ignore:80chars
      }
    'Linux': {
      $package_name = 'couchbase-server'
      $_install_options = $install_options
      $_package_provider = pick($package_provider, 'rpm')
      $_tempdir = pick($tempdir, '/tmp/')
      $_package_file = pick($package_file, 'couchbase-server-enterprise_4.0.0-centos6.x86_64.rpm') #lint:ignore:80chars
      $_wget_source = pick($wget_source, 'http://packages.couchbase.com/releases/4.0.0/couchbase-server-enterprise-4.0.0-centos6.x86_64.rpm') #lint:ignore:80chars
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

  wget::fetch { 'couchbase':
      source      => $_wget_source,
      destination => $_tempdir,
      timeout     => 60,
      verbose     => false,
      before      => Package[$package_name],
  }

  package { $package_name:
    ensure          => $package_ensure,
    source          => "${_tempdir}${_package_file}",
    install_options => $_install_options,
    provider        => $_package_provider,
  }

}

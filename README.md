## puppet-couchdb

__Puppet module for deploying Couchbase and managing its buckets.__

## Requires
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [maestrodev/wget](https://forge.puppetlabs.com/maestrodev/wget)

## Function

* Define your buckets as a hash (can use Hiera) and pass them to the Couchbase init class.

## Usage
```
# Define buckets in Hiera like this:
couchbase::buckets:
  default:
    # Remove the default bucket if present.
    #  (Newer Couchbase releases do not create a default bucket during install.)
    ensure: absent
  prod:
    # Create bucket named 'prod', disable flush, RAM size 123MB, with password.
    ensure: present
    ramsize: 123
    flush: 0
    password: hunter2
  dev:
    # Create bucket named 'dev', no password, flush enabled, 100MB RAM size.
    ramsize: 100
    flush: 1
  test:
    # Create bucket named 'test', bucket type is memcached, use defaults for everything else.
    type: memcached
  legacy:
    # Remove bucket 'legacy' if it exists.
    ensure: absent
```

* OR:

```
# Define buckets with a hash like this:

class our_profiles::my_example_profile {
  class { '::couchbase':
    cluster_ramsize  => '512',
    buckets => {
      'legacy' => { ensure => 'absent'},
      'prod'   => {
        ensure   => 'present',
        ramsize  => 123,
        flush    => 0,
        password => 'hunter2',
      }
    }
  }
}
```

## Testing

Unit tests:

```
bundle exec rake test
```

Acceptance tests:

```
bundle exec rake acceptance
bundle exec rake acceptance[centos6,onpass,yes]
```
Parameters to acceptance are: OS to test (see rakefile), BEAKER_destroy value, BEAKER_provision value
For initial test, you'd want [OS,no,yes]
For subsequent tests, you'd want [OS,no,no]
For normal cases, you can just pass [OS] and it'll only tear it down if it doesn't pass

## Reference

#### ::couchbase
*  $cluster_ramsize: __required__ Cluster's RAM size in MB as int.
*  $cluster_username: Username to auth with on cluster.
*  $cluster_password: Password to auth with on cluster.
*  $cluster_port: Cluster's port, default is '8091'
*  $cluster_host: Cluster's host, usually just 'localhost'
*  $index_path: Full path to 'nodeindex' in Couchbase's base directory
*  $data_path: Full path to 'nodedata' in Couchbase's base directory
*  $buckets: A hash of the buckets you want to manage.
*  $try_sleep: Passed to Couchbase::Cli Exec[] calls.
*  $tries: Passed to Couchbase::Cli Exec[] calls.
*  $service_ensure: (running|stopped) is passed to service declaration in Couchbase::Service
*  $package_file: (optional override) Name of install file, like "couchbase-foo-bar.1.2.3.exe"
*  $package_ensure: (installed|absent) is passed to package declaration in Couchbase::Package
*  $package_temp_dir: Full path to a good temporary directory to house the install file.
*  $package_iss_file: [WINDOWS] Name (without path) of the response file InstallShield uses to install Coucbbase headlessly.
*  $package_provider: (optional override) Passed to package declaration in Couchbase::Package and will select windows or rpm automatically.
*  $package_install_options: (optional override) Passed to package declaration in Couchbase::Package and will default to correct values automatically.
*  $wget_source: (optional override) Defaults automatically to the download URL on packages.couchbase.com
*  $file_source_base: _decomed_

#### ::couchbase::bucket
#### ::couchbase::cli
#### ::couchbase::hostinit
#### ::couchbase::package
#### ::couchbase::service
#### ::couchbase::statefile

## Limitations

Written for:
* CentOS 6
* [Windows 2008r2](https://www.microsoft.com/en-us/download/details.aspx?id=11093)

## Development

* Closed

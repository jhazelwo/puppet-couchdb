## puppet-couchdb

__A Puppet module for deploying [Couchbase Server](http://www.couchbase.com/nosql-databases/couchbase-server) and [managing its buckets](http://developer.couchbase.com/documentation/server/4.0/introduction/intro.html).__

## Requires
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [maestrodev/wget](https://forge.puppetlabs.com/maestrodev/wget)

## Function

* Define your buckets as a hash (can use Hiera) and pass them to the Couchbase init class.

## Usage

* Define buckets in Hiera like this:

```
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

* __Or__ define buckets with a hash like this:

```
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
*  $cluster_ramsize:
    * __required__
    * _integer_
    * Cluster's RAM size in MB as int.
*  $buckets:
    * _hash_
    * Default is empty hash (don't manage buckets)
    * A hash of the buckets you want to manage. (see examples)
*  $cluster_username:
    * _string_
    * Default is 'Administrator'
    * Cluster username, used in Couchbase::Cli
*  $cluster_password:
    * _string_
    * Default is 'password'
    * Cluster password, used in Couchbase::Cli
*  $cluster_port:
    * _string_
    * Default is '8091'
    * Cluster's port, used in Couchbase::Cli
*  $cluster_host:
    * _string_
    * Default is 'localhost'
    * Cluster's host, used in Couchbase::Cli
*  $index_path:
    * _string_
    * Default is automatic on CentOS:6 and Windows 2008r2
    * Full path to 'nodeindex' in Couchbase's base directory
*  $data_path:
    * _string_
    * Default is automatic on CentOS:6 and Windows 2008r2
    * Full path to 'nodedata' in Couchbase's base directory
*  $try_sleep:
    * _integer_
    * Default is 6.
    * Passed to Exec[] calls in Couchbase::Cli.
*  $tries:
    * _integer_
    * Default is 9
    * Passed to Exec[] calls in Couchbase::Cli.
*  $service_ensure:
    * _string_, (running|stopped)
    * Default is 'running'
    * Passed to service declaration in Couchbase::Service
*  $package_file:
    * _string_
    * Default is automatic on CentOS:6 and Windows 2008r2
    * Name of install file, like "couchbase-foo-bar.1.2.3.rpm"
*  $package_ensure:
    * _string_, (installed|absent)
    * Default is 'installed'
    * Passed to package declaration in Couchbase::Package
*  $package_temp_dir: Full path to a good temporary directory to house the install file. You should override this on Windows.
*  $package_iss_file: __WINDOWS__ (optional override) Name (without path) of the response file InstallShield uses to install Coucbbase headlessly.
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

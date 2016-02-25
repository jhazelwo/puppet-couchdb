## puppet-couchdb

__A Puppet module for deploying [Couchbase Server](http://www.couchbase.com/nosql-databases/couchbase-server) and [managing its buckets](http://developer.couchbase.com/documentation/server/4.0/introduction/intro.html).__

####Table of Contents

1. [Prerequisites](#requires)
2. [Module Function](#function)
3. [Usage](#usage)
    * [Examples](#examples-for-sending-api-calls-via-the-couchbase-cli)
4. [Testing](#testing)
5. [Reference](#reference)
    * [::Couchbase](#couchbase)
    * [::Couchbase::Bucket](#couchbasebucket)
    * [::Couchbase::CLI](#couchbasecli)
    * [::Couchbase::StateFile](#couchbasestatefile)
6. [Limitations](#limitations)
7. [Development](#development)
    * [Known Bugs!](#known-bugs)
    * [TODO](#todo)

## Requires
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [maestrodev/wget](https://forge.puppetlabs.com/maestrodev/wget)

## Function

This module will install Couchbase, create or join a cluster and manage buckets.

Custom commands can be sent to the couchbase-cli[.exe] binary via the Couchbase::Cli resource. This is useful for handling items such as cluster settings for which there is not yet a specific class or defined type.

## Usage

Define your buckets as a hash (can use Hiera) and pass them to the Couchbase class.

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

#### Examples for sending API calls via the Couchbase CLI:

* This will run `couchbase-cli foo-bar --thing=qaz`

```
$thing='qaz'
couchbase::cli {'do a thing':
  action      => 'foo-bar',
  parameters  => "--thing=${thing}",
}
```

* List buckets (This isn't a great example because it does not need $parameters and the output only goes to the Puppet agent log.)
    * _Equivalent to `couchbase-cli bucket-list`_
```
couchbase::cli {'bucket-list': }
```

* Enable email alerts.
    * _Equivalent to `couchbase-cli setting-alert --enable-email-alert=1`_

```
couchbase::cli {'setting-alert':
  parameters  => '--enable-email-alert=1',
}
```

* Pass multiple params using [join()](https://forge.puppetlabs.com/puppetlabs/stdlib#join) and unique $title
    * _Equivalent to `couchbase-cli ssl-manage --retrieve-cert=... --regenerate-cert='...'`_
```
$parameters = join([
  "--retrieve-cert=${retrieve_cert}",
  "--regenerate-cert='${regenerate_cert}'",
], ' ')

couchbase::cli {"manage certs for ${_site_name}":
  action     => 'ssl-manage',
  parameters => $parameters,
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

Deploy Couchbase

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
    * Full path to 'nodeindex' in Couchbase's base directory. Used by Couchbase::Hostinit.
*  $data_path:
    * _string_
    * Default is automatic on CentOS:6 and Windows 2008r2
    * Full path to 'nodedata' in Couchbase's base directory. Used by Couchbase::Hostinit.
*  $try_sleep:
    * _integer_
    * Default is 6.
    * Passed to Exec[] calls in Couchbase::Cli. The high default values of $try_sleep and $tries are usually only needed during Couchbase installation because it takes some extra time after the package is installed before the daemon can start accepting API calls. Feel free to set both of these to 0 at any time but understand that it may take 2 or more Puppet agent (non-idempotent) runs before reaching convergence.
*  $tries:
    * _integer_
    * Default is 9
    * Passed to Exec[] calls in Couchbase::Cli. See also $try_sleep.
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
    * TODO: May be replaced with present=>'true|false'
*  $package_temp_dir:
    * _string_
    * Default is automatically 'c:/' or '/tmp/'
    * Full path to a good temporary directory to house the install file. __You should override this on Windows__ because 'c:/' isn't a good temporary folder.
*  $package_iss_file:
    * __WINDOWS__  
    * _string_
    * Default is 'couchbase400.iss'
    * Name (without path) of the response file InstallShield uses to install Couchbase headlessly.
*  $package_provider:
    * _string_
    * Default is automatically 'windows' or 'rpm'.
    * Passed to the package declaration in Couchbase::Package.
*  $package_install_options:
    * _string_ or _list_
    * Default is automatic depending on OS.
    * Passed to the package declaration in Couchbase::Package
*  $wget_source:
    * _string_
    * Default is automatic depending on OS.
    * Full URL (including file name) to get the .exe or .rpm install file.
*  $file_source_base:
    * _decomed_

#### ::couchbase::bucket

Define a bucket in Couchbase

* $title
    * _string_
    * Name of the bucket.
* $ensure
    * _string_ (present|absent)
    * Default is 'present'
    * Whether to create or remove bucket named $title. Will __delete__ bucket if set to 'absent', but any other value will translate to 'present'.
    * TODO: May be replaced with present=>'true|false'
* $flush
    * _integer_ (but treated as string)
    * Default is 0
    * Enable/disable flush. Passed to "--enable-flush=" parameter during bucket create.
* $replica
    * _integer_ (but treated as string)
    * Default is 0
    * Replica count. Passed to "--bucket-replica=" parameter during bucket create.
* $enable_index_replica
    * _integer_ (but treated as string)
    * Default is 0
    * Enables number of replicas. Passed to "--enable-index-replica=" parameter during bucket create.
* $ramsize
    * _integer_
    * Default is 100
    * Memory size, in MB, allocated to bucket.
* $port
    * _integer_
    * Default is 11211
    * "TCP port 11211 with SASL authentication, or a dedicated port with no password". Passed to "--bucket-port=" during bucket create.
* $type
    * _string_ (couchbase|memcached)
    * Default is 'couchbase'
    * Type of bucket, passed to "--bucket-type=" during bucket create. Cannot be changed after bucket is created.
* $password
    * _string_
    * Default is none.
    * Bucket-specific SASL password. This is an optional parameter passed to "--bucket-password=" during bucket create.
* $couchbase_etc
    * _string_
    * Defaults to value of $etc_path in ::couchbase which is determined automatically based on operating system. ('/opt/couchbase/etc/'|'C:/Program Files/Couchbase/Server/etc/')
    * Full path to Couchbase's /etc/ directory.

#### ::couchbase::cli

Run the couchbase-cli[.exe] command with arguments.

* $action
    * _string_
    * Default is $title
    * First argument given to cli.
* $creates
    * _path_
    * Passed to 'creates' in the Exec[] resource. One or more file paths that the cli command is expected to create.
* $exec_cwd
    * _path_
    * Default is base directory of Couchbase installation.
    * Overrides 'cwd' in the Exec[] resource.
* $exec_title
    * _string_
    * Default is "${title} ${action} ${parameters}"
    * Overrides $title of the Exec[] resource.
* $exec_loglevel
    * _string_
    * Default is 'notice'
    * Overrides 'loglevel' in the Exec[] resource.
* $onlyif
    * _string_
    * $action and $parameters of a Couchbase::Cli call which gets parsed and aassed to 'onlyif' of the Exec[] resource as a complete command..
* $parameters
    * _string_
    * Arguments to run.
* $refreshonly
    * _bool_
    * Default is false
    * Overrides 'refreshonly' in the Exec[] resource.
* $returns
    * _integer_ (or list of integers)
    * Default is 0
    * Overrides 'returns' in the Exec[] resource.
* $tries
    * _integer_
    * Default is $::couchbase::tries
    * Overrides 'tries' in the Exec[] resource.
* $try_sleep
    * _integer_
    * Default is $::couchbase::try_sleep
    * Overrides 'tries' in the Exec[] resource.
* $unless
    * _string_
    * $action and $parameters of a Couchbase::Cli call which gets parsed and aassed to 'onlyif' of the Exec[] resource as a complete command..
* $cli
    * _path_
    * Default is automatically determined based on OS.
    * Full path to the couchbase-cli[.exe] command.
* $username
    * _string_
    * Default is $::couchbase::cluster_username,
    * Username used to authenticate in the cluster.
* $password
    * _string_
    * Default is $::couchbase::cluster_password,
    * Password used to authenticate in the cluster.

#### ::couchbase::statefile

Define local trigger files to pass state information between CouchDB and Puppet.

* $title:
    * _string_
    * Used in name of state file.
* $content:
    * _string_
    * Default is ''
    * Text to put in the state file.
* $ensure:
    * _string_ ('file'|'absent')
    * Default is 'file'
    * Manage or remove the state file. Will delete the file if set to 'absent', but any other value will be treated as 'file'.
    * TODO: May be replaced with present=>'true|false'
* $do_notify:
    * _resource_
    * Default is Couchbase::Cli[$title]
    * Resource to notify when state file contents change.
* $etc_path:
    * _string_
    * Default is automatic based on OS.
    * Full path to Couchbase's /etc/ directory (ex: '/opt/couchbase/etc/')
* $msg_prefix:
    * _string_
    * Default is "# Stafefile for ${title}, do not edit! \n"
    * Text added to state file before $content

## Limitations

Module written and tested on these operating systems:

* CentOS 6
* [Windows 2008r2](https://www.microsoft.com/en-us/download/details.aspx?id=11093)

_Should work on other operating systems that [Couchbase supports](http://developer.couchbase.com/documentation/server/4.0/install/install-platforms.html) if you override the appropriate parameters (your mileage may vary)._

## Development

* __Closed__. Not accepting issues or pull requests at this time. _2016.02-JH_

#### Known Bugs:

1. Failed CLI calls that are generated from statefile changes lead to split-mind. For example, adding a bucket when there is no more room in the cluster will create a statefile without creating a bucket and manual detection and intervention is required.

#### TODO:

* Template the iss files, pass installdir
* cbepctl.pp
* settings.pp
* acceptance tests
* expand OS support to match Couchbase's supporting platforms.
    * match spec tests
* add back and integrate local source support in couchbase::package on toggle
    * $use_wget = true|false

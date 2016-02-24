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
      'default' => { ensure => 'absent'},
      'prod'    => {
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

Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

## Limitations

Written for:
* CentOS 6
* [Windows 2008r2](https://www.microsoft.com/en-us/download/details.aspx?id=11093)

## Development

* Closed

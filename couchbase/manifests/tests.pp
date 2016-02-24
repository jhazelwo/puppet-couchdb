#
# Couchbase smoke tests.

#lint:ignore:arrow_alignment
#lint:ignore:80chars
#lint:ignore:double_quoted_strings

class couchbase::tests {
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

#lint:endignore
#lint:endignore
#lint:endignore

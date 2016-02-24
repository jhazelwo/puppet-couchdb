#
# Couchbase smoke tests.

#lint:ignore:arrow_alignment
#lint:ignore:80chars
#lint:ignore:double_quoted_strings

class couchbase::tests {
  class { '::couchbase':
    cluster_ramsize  => '512',
  }
}

#lint:endignore
#lint:endignore
#lint:endignore

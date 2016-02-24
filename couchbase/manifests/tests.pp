#
# Couchbase smoke tests.

#lint:ignore:arrow_alignment
#lint:ignore:80chars
#lint:ignore:double_quoted_strings

class couchbase::tests {
  $p = 'couchbase-server-enterprise-4.0.0-centos6.x86_64.rpm'
  #$p = 'couchbase-server-enterprise_4.0.0-windows_amd64.exe'
  #$t = 'c:/Users/Public/'

  class { '::couchbase':
    package_file     => $p,
    cluster_ramsize  => '512',
  }

}

#lint:endignore
#lint:endignore
#lint:endignore

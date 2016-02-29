#
class our_profiles::profile_for_couchbase_on_debian7 {

  class { '::couchbase':
    # Untested, but this is basically what you need to do:
    package_provider => 'apt',
    wget_source      => 'http://packages.couchbase.com/releases/4.0.0/couchbase-server-community_4.0.0-debian7_amd64.deb',
    package_file     => 'couchbase-server-community_4.0.0-debian7_amd64.deb',

    cluster_ramsize  => '512',

    buckets => {

      'prod'   => {
        ramsize  => 123,
        flush    => 0,
        password => 'hunter2',
      }

    }

  }

}

#
class our_profiles::my_example_profile {

  class { '::couchbase':

    cluster_ramsize  => '512',

    buckets => {

      'legacy' => { present => false },

      'prod'   => {
        ramsize  => 123,
        flush    => 0,
        password => 'hunter2',
      }

    }

  }

}

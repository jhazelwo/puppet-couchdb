require 'spec_helper'

supported_oses = {}.merge!(on_supported_os)
RspecPuppetFacts.meta_supported_os.each do |os|
  if os['operatingsystem'] =~ /windows/i
    os['operatingsystemrelease'].each do |release|
      os_string = "#{os['operatingsystem']}-#{release}"
      supported_oses[os_string] = {
        :operatingsystem => 'windows',
        :kernelversion => '6.3.9600', # Just defaulting to 2012r2
      }
    end
  end
end

describe 'couchbase' do
  context 'supported operating systems' do
    supported_oses.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        context 'couchbase class without any parameters error' do
          it { expect { is_expected.to contain_class('couchbase') }.to raise_error(Puppet::Error, /Must pass /) }
        end
        context 'couchbase class with basic parameters' do
          let(:params) do
            {
              'cluster_ramsize' => '512',
              'buckets' => {
                'test' => {
                  'ramsize' => '100',
                  'present' => true,
                },
                'legacy' => {
                  'present' => false,
                }
              }
            }
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('couchbase') }
          it { is_expected.to contain_class('couchbase::package') }
          it { is_expected.to contain_class('couchbase::service') }
          it { is_expected.to contain_class('couchbase::hostinit') }
          it { is_expected.to contain_couchbase__cli('node-init') }
          it { is_expected.to contain_couchbase__cli('cluster-init') }
          it { is_expected.to contain_exec('cluster-init') }
          it { is_expected.to contain_exec('couchbase::hostinit') }
          it { is_expected.to contain_package('couchbase-server') }
          it { is_expected.to contain_exec('wget-couchbase') }
          it { is_expected.to contain_wget__fetch('couchbase') }
          it { is_expected.to contain_service('couchbase-server') }
          it { is_expected.to contain_couchbase__bucket('test') }
          it { is_expected.to contain_couchbase__cli('bucket-create test') }
          it { is_expected.to contain_couchbase__statefile('bucket-test') }
          it { is_expected.to contain_exec('bucket-create test') }
          it { is_expected.to contain_file('bucket-test') }
          it { is_expected.to contain_couchbase__bucket('legacy') }
          it { is_expected.to contain_couchbase__cli('bucket-delete legacy') }
          it { is_expected.to contain_couchbase__statefile('bucket-legacy') }
          it { is_expected.to contain_exec('bucket-delete legacy') }
          it { is_expected.to contain_file('bucket-legacy') }
        end
      end
    end
  end
end

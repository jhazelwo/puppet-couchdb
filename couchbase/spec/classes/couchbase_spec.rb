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
              'package_file' => 'couchbase-server-enterprise-4.0.0-centos6.x86_64.rpm',
              'cluster_ramsize' => '512',
            }
          end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('couchbase') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end

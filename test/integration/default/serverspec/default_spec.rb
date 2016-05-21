require 'serverspec'
set :backend, :exec

describe service('consul-replicate') do
  it { should be_enabled }
  it { should be_running }
end

describe process('consul-replicate') do
  its(:count) { should eq 1 }
  its(:user) { should eq 'consul' }
  its(:group) { should eq 'consul' }
  its(:args) { should match '-config /etc/consul/replicate.json' }
  it { should be_running }
end


describe user('consul') do
  it { should exist }
end

describe file('/etc/consul/replicate.json') do
  it { should be_file }
  it { should be_owned_by 'consul' }
  it { should be_grouped_into 'consul' }
end

describe file('/opt/consul-replicate/0.2.0/consul-replicate') do
  it { should be_file }
  it { should be_executable }
end

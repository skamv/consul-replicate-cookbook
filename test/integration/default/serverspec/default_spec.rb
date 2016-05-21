require 'serverspec'
set :backend, :exec

describe service('consul-replicate') do
  it { should be_enabled }
  it { should be_running }
end

describe user('consul') do
  it { should exist }
end

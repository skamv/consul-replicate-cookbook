#
# Cookbook: consul-replicate
# License: Apache 2.0
#
# Copyright 2016, Bloomberg Finance L.P.
#
poise_service_user node['consul-replicate']['service_user'] do
  group node['consul-replicate']['service_group']
  not_if { user == 'root' }
end

directory node['consul-replicate']['service_directory'] do
  recursive true
  owner node['consul-replicate']['service_user']
  group node['consul-replicate']['service_group']
end

consul = consul_replicate_installation node['consul-replicate']['service_name'] do
  version node['consul-replicate']['version']
end

config = consul_replicate_config node['consul-replicate']['service_name'] do |r|
  owner node['consul-replicate']['service_user']
  group node['consul-replicate']['service_user']
  if node['consul-replicate']['config']
    node['consul-replicate']['config'].each_pair { |k, v| r.send(k, v) }
  end
end

poise_service node['consul-replicate']['service_name'] do
  command "#{consul.program} -config #{config.path}"
  user node['consul-replicate']['service_user']
  directory node['consul-replicate']['service_directory']
  subscribes :reload, "rc_file[#{config.path}]", :delayed
end

#
# Cookbook: consul-replicate
# License: Apache 2.0
#
# Copyright 2016, Bloomberg Finance L.P.
#
default['consul-replicate']['version'] = '0.2.0'

default['consul-replicate']['service_user'] = 'consul'
default['consul-replicate']['service_group'] = 'consul'
default['consul-replicate']['service_name'] = 'consul-replicate'
default['consul-replicate']['service_directory'] = '/var/run/consul-replicate'

default['consul-replicate']['config']['path'] = '/etc/consul/replicate.json'

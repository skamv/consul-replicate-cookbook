# consul-replicate cookbook [![Build Status](https://img.shields.io/travis/johnbellone/consul-replicate-cookbook.svg)](https://travis-ci.org/johnbellone/consul-replicate-cookbook) [![Code Quality](https://img.shields.io/codeclimate/github/johnbellone/consul-replicate-cookbook.svg)](https://codeclimate.com/github/johnbellone/consul-replicate-cookbook) [![Cookbook Version](https://img.shields.io/cookbook/v/consul-replicate.svg)](https://supermarket.chef.io/cookbooks/nrpe-ng)

[Application cookbook][0] which installs and configures the
[Consul Replicate][2] daemon.

## Platforms
The following platforms are tested using [Test Kitchen][1]:

- Ubuntu 12.04/14.04/16.04
- CentOS (RHEL) 5/6/7
- FreeBSD 9/10

## Basic Usage
The [default recipe](recipes/default.rb) installs and configures the
Consul Replicate daemon. The
[install resource](libraries/consul_installation.rb) will use the
[archive install provider](libraries/consul_replicate_installation_archive.rb)
for the node's operating system. The configuration of the daemon is
managed through the [config resource](libraries/consul_replicate_config.rb) which
can be tuned with node attributes.

[0]: http://blog.vialstudios.com/the-environment-cookbook-pattern#theapplicationcookbook
[1]: https://github.com/test-kitchen/test-kitchen
[2]: https://github.com/hashicorp/consul-replicate

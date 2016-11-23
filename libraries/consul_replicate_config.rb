#
# Cookbook: consul-replicate
# License: Apache 2.0
#
# Copyright 2016, Bloomberg Finance L.P.
#
require 'poise'

module ConsulReplicateCookbook
  module Resource
    class ConsulReplicateConfig < Chef::Resource
      include Poise(fused: true)
      provides(:consul_replicate_config)

      # @!attribute path
      # @return [String]
      attribute(:path, kind_of: String, default: '/etc/consul/replicate.json')
      # @!attribute owner
      # @return [String]
      attribute(:owner, kind_of: String, default: 'consul')
      # @!attribute group
      # @return [String]
      attribute(:group, kind_of: String, default: 'consul')
      # @!attribute mode
      # @return [String]
      attribute(:mode, kind_of: String, default: '0640')

      # @!attribute consul
      # @return [String]
      attribute(:consul, kind_of: String, default: '127.0.0.1:8500')
      # @!attribute token
      # @return [String]
      attribute(:token, kind_of: String)
      # @!attribute retry
      # @return [String]
      attribute(:retry, kind_of: String, default: '10s')
      # @!attribute max_stale
      # @return [String]
      attribute(:max_stale, kind_of: String, default: '10m')
      # @!attribute wait
      # @return [String]
      attribute(:wait, kind_of: String)
      # @!attribute log_level
      # @return [String]
      attribute(:log_level, equal_to: %w{debug info err}, default: 'info')
      # @!attribute syslog_enabled
      # @return [TrueClass, FalseClass]
      attribute(:syslog_enabled, equal_to: [true, false], default: false)
      # @!attribute syslog_facility
      # @return [String]
      attribute(:syslog_facility, kind_of: String, default: 'local0')
      # @!attribute ssl_enabled
      # @return [TrueClass, FalseClass]
      attribute(:ssl_enabled, equal_to: [true, false], default: false)
      # @!attribute ssl_verify
      # @return [TrueClass, FalseClass]
      attribute(:ssl_verify, equal_to: [true, false], default: true)
      # @!attribute auth_enabled
      # @return [TrueClass, FalseClass]
      attribute(:auth_enabled, equal_to: [true, false], default: false)
      # @!attribute auth_username
      # @return [String]
      attribute(:auth_username, kind_of: String)
      # @!attribute auth_username
      # @return [String]
      attribute(:auth_password, kind_of: String)
      # @!attribute prefix
      # @return [Array]
      attribute(:prefix, kind_of: Array, default: [])
      # @!attribute exclude
      # @return [Array]
      attribute(:exclude, kind_of: Array, default: [])

      def variables
        {
          consul: consul,
          retry: self.retry,
          max_stale: max_stale,
          log_level: log_level,
          prefix: prefix
        }.tap do |h|
          h['token'] = token unless token.nil?
          h['wait'] = wait unless wait.nil?
          h['exclude'] = exclude unless exclude.empty?

          if auth_enabled
            h['auth'] = {}
            h['auth']['enabled'] = true
            h['auth']['username'] = auth_username
            h['auth']['password'] = auth_password
          end

          if syslog_enabled
            h['syslog'] = {}
            h['syslog']['enabled'] = true
            h['syslog']['facility'] = syslog_facility
          end

          if ssl_enabled
            h['ssl'] = {}
            h['ssl']['enabled'] = true
            h['ssl']['verify'] = ssl_verify
            h['ssl']['cert'] = ssl_cert
            h['ssl']['key'] = ssl_key
            h['ssl']['ca_cert'] = ssl_ca_cert
          end
        end
      end

      action(:create) do
        directory ::File.dirname(new_resource.path) do
          recursive true
        end

        rc_file new_resource.path do
          type 'json'
          options new_resource.variables
          owner new_resource.owner
          group new_resource.group
          mode new_resource.mode
        end
      end

      action(:delete) do
        notifying_block do
          file new_resource.path do
            action :delete
          end
        end
      end
    end
  end
end

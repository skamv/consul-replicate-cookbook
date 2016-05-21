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
      attribute(:path, kind_of: String, default: '/etc/consul-replicate.json')
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
      attribute(:token, kind_of: String, default: '')
      # @!attribute retry
      # @return [String]
      attribute(:retry, kind_of: String, default: '10s')
      # @!attribute max_stale
      # @return [String]
      attribute(:max_stale, kind_of: String, default: '10m')
      # @!attribute log_level
      # @return [String]
      attribute(:log_level, equal_to: %w{debug info}, default: 'info')
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
      attribute(:auth_enabled, equal_to: [true, false], default: true)
      # @!attribute auth_username
      # @return [String]
      attribute(:auth_username, kind_of: String, default: '')
      # @!attribute auth_username
      # @return [String]
      attribute(:auth_password, kind_of: String, default: '')
      # @!attribute prefix
      # @return [Array]
      attribute(:prefix, kind_of: Array[Hash], default: [])

      def variables
        {
         consul: consul,
         token: token,
         retry: self.retry,
         max_stale: max_stale,
         log_level: log_level,
         auth: {enabled: auth_enabled, username: auth_username, password: auth_password},
         ssl: {enabled: ssl_enabled, verify: ssl_verify},
         syslog: {enabled: syslog_enabled, facility: syslog_facility},
         prefix: prefix,
        }
      end

      action(:create) do
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

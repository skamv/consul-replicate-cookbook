#
# Cookbook: consul-replicate
# License: Apache 2.0
#
# Copyright 2016, Bloomberg Finance L.P.
#
require 'poise'

module ConsulReplicateCookbook
  module Resource
    # A `consul_replicate_installation` resource which manages the
    # Consul Replicate installation for this node.
    # @action create
    # @action remove
    # @since 1.0
    class ConsulReplicateInstallation < Chef::Resource
      include Poise(inversion: true)
      provides(:consul_replicate_installation)
      actions(:create, :remove)
      default_action(:create)

      # @!attribute version
      # @return [String]
      attribute(:version, kind_of: String, default: '0.2.0')

      def program
        @program ||= provider_for_action(:program).program
      end
    end
  end
end

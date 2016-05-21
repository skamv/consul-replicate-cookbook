#
# Cookbook: consul-replicate
# License: Apache 2.0
#
# Copyright 2016, Bloomberg Finance L.P.
#
require 'poise'

module ConsulReplicateCookbook
  module Provider
    # A `consul_replicate_installation` provider which manages the
    # Consul Replicate archive installation.
    # @action create
    # @action delete
    # @since 1.0
    class ConsulReplicateInstallationArchive < Chef::Provider
      include Poise(inversion: :consul_replicate_installation)
      provides(:archive)

      # @api private
      def self.provides_auto?(_node, _resource)
        true
      end

      # Set the default inversion options.
      # @param [Chef::Node] node
      # @param [Chef::Resource] resource
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, resource)
        super.merge(prefix: '/opt/consul-replicate',
          version: resource.version,
          archive_url: default_archive_url,
          archive_basename: default_archive_basename(node, resource),
          archive_checksum: default_archive_checksum(node, resource))
      end

      def action_create
        url = options[:archive_url] % {version: options[:version], basename: options[:archive_basename]}
        notifying_block do
          directory options[:prefix] do
            recursive true
          end

          poise_archive ::File.basename(url) do
            action :nothing
            path ::File.join(Chef::Config[:file_cache_path], name)
            destination consul_base
          end

          remote_file ::File.basename(url) do
            source url
            checksum options[:archive_checksum]
            path ::File.join(Chef::Config[:file_cache_path], name)
            notifies :unpack, "poise_archive[#{name}]", :immediately
          end
        end
      end

      def action_delete
        notifying_block do
          directory consul_base do
            recursive true
            action :delete
          end
        end
      end

      # @return [String]
      # @api private
      def consul_base
        ::File.join(options[:prefix], new_resource.version)
      end

      # @return [String]
      # @api private
      def program
        options.fetch(:program, ::File.join(consul_base, 'consul-replicate'))
      end

      # @return [String]
      def self.default_archive_url
        "https://releases.hashicorp.com/consul-replicate/%{version}/%{basename}" # rubocop:disable Style/StringLiterals
      end

      # @param [Chef::Node] node
      # @param [Chef::Resource] resource
      # @return [String]
      def self.default_archive_basename(node, resource)
        case node['kernel']['machine']
        when 'x86_64', 'amd64' then ['consul-replicate', resource.version, node['os'], 'amd64'].join('_')
        when /i\d86/ then ['consul-replicate', resource.version, node['os'], '386'].join('_')
        else ['consul-replicate', resource.version, node['os'], node['kernel']['machine']].join('_')
        end.concat('.zip')
      end

      # @param [Chef::Node] node
      # @param [Chef::Resource] resource
      # @return [String]
      def self.default_archive_checksum(node, resource)
        tag = node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : node['kernel']['machine']
        case [node['os'], tag].join('-')
        when 'darwin-i386'
          case resource.version
          when '0.1.0' then '0f1e37457c715942f92bdc2aba039a628d7e036e403fceadb0fcfacfe07dc68e'
          when '0.2.0' then '223a3f0b9eef6600ac51596ea4074cb1f06d085824a113ecceeb610b01982bd2'
          end
        when 'darwin-amd64'
          case resource.version
          when '0.1.0' then '3ee227d50ce3764552bbe5c9eee3dc73e42c83746abaf684b6999d3116f8e03c'
          when '0.2.0' then '4d5c944e33630750b5d73ae7f9fc0510322dd60efa04aaefa939bc0d59e93885'
          end
        when 'freebsd-i386'
          case resource.version
          when '0.1.0' then '3de903b70dd1580a204d0db8fcd5aa1348ab5b4890eefecb0e11a95c550e1474'
          when '0.2.0' then 'd9fc089d23ca3af597986032294a2cc8e4de8b421022620b275b09cd4ffd256f'
          end
        when 'freebsd-amd64'
          case resource.version
          when '0.1.0' then '7914a6d9d21fb0833ad50afa884ae947c4b45a23aa7e58b6878beb087aa0fba7'
          when '0.2.0' then '0e0eef0588599122c1e8cd1c37d8c821a2401e63c55ad4a792633ca47bdc4dc6'
          end
        when 'freebsd-arm'
          case resource.version
          when '0.1.0' then 'a3adf8425c93979ed4aa5c1792885bd57739a8079ff46ad1b57c98d75ca86272'
          when '0.2.0' then '24fb42ff07edfeab8a061c571ee2a35a47f42701b922de82708d80dfb7d41946'
          end
        when 'linux-i386'
          case resource.version
          when '0.1.0' then '1160dcd2bdb8856b7b99e7c3f0256d769bd5a1c80ae42d31bc51bc05a6d7e2ad'
          when '0.2.0' then '1f23440eda43ddf2998665f280ecbd64b4ae686334207fe569d7d73e96c19bfd'
          end
        when 'linux-amd64'
          case resource.version
          when '0.1.0' then 'bd383d089791d8eb45fc51035d758ed2fcbe3a603ca44edd785c874c94a54770'
          when '0.2.0' then '591d073718ec9abeaf5974e9e9d8c058780342c5a14dade059f8082173549fe8'
          end
        when 'linux-arm'
          case resource.version
          when '0.1.0' then '1bc1f218d0eb85abcecb508a5972298d39e2703243f24f83a70c415a59cd70b0'
          when '0.2.0' then 'bbb123af1a553af73f60716b7de844f126549d2f5b3d0694fb6ebfad90c4b944'
          end
        when 'netbsd-386'
          case resource.version
          when '0.1.0' then 'f348cc99f241c5105afbec53834d92e9cf07c2854f910ace0473689c5d47a37c'
          when '0.2.0' then '7dcc18adae95915a021e1e4473ba28b6e1bd1659a11d2929842e0e2635512ee2'
          end
        when 'netbsd-amd64'
          case resource.version
          when '0.1.0' then '30270b3d634d5e8425aa526a4c0807bfc8e37e78ade16c0cce8eefabe176f1f3'
          when '0.2.0' then 'f3178ead41c9dda56afa6ef718207f48dad07503e13ad4276ae8454a2bd92f5b'
          end
        when 'netbsd-arm'
          case resource.version
          when '0.1.0' then '869c651d46f9d0aca7c33ad033472b89129dd31afb20b9574ffdcd4df1d590a4'
          when '0.2.0' then '6d5cc949d565cd8305f0684aae95b7b1cb2d08ed8521f27ca2eed8c1690b5782'
          end
        when 'openbsd-386'
          case resource.version
          when '0.1.0' then '1c0db1eb4b55632f0e0b761eec5ba750a582e3db39aa76fffc8355f152e3134b'
          when '0.2.0' then '1ca727580aa999c4375e4b9c41603f4c7d3f347da1c4ca37a2d1fee6f848801b'
          end
        when 'openbsd-amd64'
          case resource.version
          when '0.1.0' then '28f3e87564b05ab6cd2ee8aa27398e2df9adbe1a4ffeaeb82c77a1d129528b6c'
          when '0.2.0' then 'ecaf664fce62706e3d58f9eb2ca66a53ae9eb7787477869959c3f6ebf5512664'
          end
        when 'plan9-386'
          case resource.version
          when '0.1.0' then 'db86649b2a5c7505975bbb5bebf58d6eabb36ef665c67cbb02c7a4ea1b017489'
          end
        when 'windows-i386'
          case resource.version
          when '0.1.0' then 'bee29dcaf9a418c878421786669aefb9e912cb716e952779ec11838fe1fdff46'
          when '0.2.0' then '549e69e4c9e811da3889bb9045df28895bc0a681547e79c33ce29e39f7c7c9ba'
          end
        when 'windows-amd64'
          case resource.version
          when '0.1.0' then '936f4cee0f49f08b3781f0555134b56ce755cd748f38cafc42312805a12f3853'
          when '0.2.0' then '8cdd86c6e184eae627dfcdc56a28de86c80076433a563f8147ad41f8a8fa5ea0'
          end
        end
      end
    end
  end
end

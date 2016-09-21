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
          directory consul_base do
            recursive true
          end

          remote_file ::File.basename(url) do
            source url
            checksum options[:archive_checksum]
            path ::File.join(Chef::Config[:file_cache_path], name)
          end

          poise_archive ::File.basename(url) do
            path ::File.join(Chef::Config[:file_cache_path], name)
            destination consul_base
            strip_components 0
          end

          file program do
            mode '0755'
            only_if { ::File.exist?(path) }
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
          when '0.2.0' then '32c75f4fb2ba51763102e8f2fab4ad0e7e09f9fe474959934e37a56930507ee5'
          end
        when 'darwin-amd64'
          case resource.version
          when '0.1.0' then '3ee227d50ce3764552bbe5c9eee3dc73e42c83746abaf684b6999d3116f8e03c'
          when '0.2.0' then '48956988c2f3d963930f48f26fe16c3dee9eede8719de002940f18802195c190'
          end
        when 'freebsd-i386'
          case resource.version
          when '0.1.0' then '3de903b70dd1580a204d0db8fcd5aa1348ab5b4890eefecb0e11a95c550e1474'
          when '0.2.0' then 'fdeace1b1dffd58958aad8954263c709c154f4e5c9db767c1b62d352227ce0f9'
          end
        when 'freebsd-amd64'
          case resource.version
          when '0.1.0' then '7914a6d9d21fb0833ad50afa884ae947c4b45a23aa7e58b6878beb087aa0fba7'
          when '0.2.0' then '1b10091f59be4dd0f4c924f337c6002cefd2bc65f115f4641946ca5b27ecb5a2'
          end
        when 'freebsd-arm'
          case resource.version
          when '0.1.0' then 'a3adf8425c93979ed4aa5c1792885bd57739a8079ff46ad1b57c98d75ca86272'
          when '0.2.0' then '718c6abb0e0efc1b9b9440740ab2bf46c1ec2e77c4b2e55e9e76289460c544e5'
          end
        when 'linux-i386'
          case resource.version
          when '0.1.0' then '1160dcd2bdb8856b7b99e7c3f0256d769bd5a1c80ae42d31bc51bc05a6d7e2ad'
          when '0.2.0' then 'ccc522a7a9cacdfae390c6f5b94654d2dcbf3bfcd4bdc7f49d63ce70a307d96b'
          end
        when 'linux-amd64'
          case resource.version
          when '0.1.0' then 'bd383d089791d8eb45fc51035d758ed2fcbe3a603ca44edd785c874c94a54770'
          when '0.2.0' then 'cc7ffbc3f78efd303861164cde1f09d5c6fd5854d13d8c318d92a71d2b69447a'
          end
        when 'linux-arm'
          case resource.version
          when '0.1.0' then '1bc1f218d0eb85abcecb508a5972298d39e2703243f24f83a70c415a59cd70b0'
          when '0.2.0' then 'bbfc42dc8904e0fc7cf4bb97feddb1cc7139f9fa1510e8b42ccf9fefbf821a2a'
          end
        when 'netbsd-386'
          case resource.version
          when '0.1.0' then 'f348cc99f241c5105afbec53834d92e9cf07c2854f910ace0473689c5d47a37c'
          when '0.2.0' then '07436456f6e2af64947306568e11231d0c6403461a5be3e9ef8be7ebd50623af'
          end
        when 'netbsd-amd64'
          case resource.version
          when '0.1.0' then '30270b3d634d5e8425aa526a4c0807bfc8e37e78ade16c0cce8eefabe176f1f3'
          when '0.2.0' then 'c89b8ffbd1646fee8cabe540804864a7bb7ff0ea3bd259c6d96fba62a6c8a6cd'
          end
        when 'netbsd-arm'
          case resource.version
          when '0.1.0' then '869c651d46f9d0aca7c33ad033472b89129dd31afb20b9574ffdcd4df1d590a4'
          when '0.2.0' then 'df59a25ef2d70b827d23d651095d6fbabbd3e4b1d45e12c7797b4efc93369e12'
          end
        when 'openbsd-386'
          case resource.version
          when '0.1.0' then '1c0db1eb4b55632f0e0b761eec5ba750a582e3db39aa76fffc8355f152e3134b'
          when '0.2.0' then 'a295d01de396715696d901185cc87ef4d8b807723ee94af2596b66c539992dde'
          end
        when 'openbsd-amd64'
          case resource.version
          when '0.1.0' then '28f3e87564b05ab6cd2ee8aa27398e2df9adbe1a4ffeaeb82c77a1d129528b6c'
          when '0.2.0' then '26c073ceadb391d223f5b9e5641792b2b1f9cd180407a6acb23e083ead7a7bd5'
          end
        when 'plan9-386'
          case resource.version
          when '0.1.0' then 'db86649b2a5c7505975bbb5bebf58d6eabb36ef665c67cbb02c7a4ea1b017489'
          end
        when 'windows-i386'
          case resource.version
          when '0.1.0' then 'bee29dcaf9a418c878421786669aefb9e912cb716e952779ec11838fe1fdff46'
          when '0.2.0' then '04f3b3a97eb7599c5a6f92841caf58300e62b1ac089ea3b8e29bd360ed04aaeb'
          end
        when 'windows-amd64'
          case resource.version
          when '0.1.0' then '936f4cee0f49f08b3781f0555134b56ce755cd748f38cafc42312805a12f3853'
          when '0.2.0' then '1c0ca471901ea9f6954f17c515a4c7367241bf7ba40e664b18157412614e8580'
          end
        end
      end
    end
  end
end

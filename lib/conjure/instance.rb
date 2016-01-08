require "conjure/docker/host"
require "conjure/firewall"
require "conjure/rails_application"
require "conjure/server"
require "conjure/swap"
require "yaml"

module Conjure
  class Instance
    def initialize(ip_address, options)
      @server = Server.new ip_address
      @options = options
    end

    def self.create(options)
      @server = Server.create server_name_prefix(options), options
      new(@server.ip_address, options).tap(&:update)
    end

    def self.update(options)
      ip_address = options.delete(:ip_address)
      new(ip_address, options).tap(&:update)
    end

    def update
      components.each(&:install)
    end

    def ip_address
      @server.ip_address
    end

    def port
      2222
    end

    def user
      "app"
    end

    def pending_files
      components.flat_map(&:pending_files)
    end

    private

    def self.server_name_prefix(options)
      "#{options[:app_name]}-#{options[:rails_env]}"
    end

    def components
      @components ||= [
        Firewall.new(@server),
        Swap.new(@server),
        RailsApplication.new(Docker::Host.new(@server), @options),
      ]
    end
  end
end

require "conjure/docker/template"
require "conjure/server"
require "conjure/swap"
require "conjure/postgres"
require "conjure/passenger"
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
        Swap.new(@server),
        database = Postgres.new(@server),
        Passenger.new(@server, @options.merge(database: database)),
      ]
    end
  end
end

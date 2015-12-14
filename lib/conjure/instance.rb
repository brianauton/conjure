require "conjure/docker/template"
require "conjure/server"
require "conjure/swap"
require "conjure/postgres"
require "conjure/passenger"
require "yaml"

module Conjure
  class Instance
    def initialize(options = {})
      @options = options
    end

    def provision(options = {})
      @server = Server.create server_name_prefix, @options
      components.each(&:install)
      {
        :ip_address => @server.ip_address,
        :port => 2222,
        :user => "app",
        :pending_files => components.flat_map(&:pending_files),
      }
    end

    private

    def server_name_prefix
      "#{@options[:app_name]}-#{@options[:rails_env]}"
    end

    def components
      @components ||= [
        Swap.new(@server),
        database = Postgres.new(@server),
        Passenger.new(@server, database, @options[:rails_env], @options),
      ]
    end
  end
end

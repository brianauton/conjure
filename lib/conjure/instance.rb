require "conjure/docker/template"
require "conjure/server"
require "conjure/swap"
require "conjure/postgres"
require "conjure/passenger"
require "yaml"

module Conjure
  class Instance
    def initialize(app_name, rails_env, options = {})
      @app_name = app_name
      @rails_env = rails_env
      @options = options
    end

    def provision(options = {})
      @server = Server.create "#{@app_name}-#{@rails_env}", @options
      components.each(&:install)
      sleep 1
      remote_command "root@#{@server.ip_address} -p 2222", "/etc/init.d/nginx restart"
      {
        :ip_address => @server.ip_address,
        :port => 2222,
        :user => "app",
        :rails_env => @rails_env,
        :pending_files => components.flat_map(&:pending_files),
      }
    end

    private

    def components
      @components ||= [
        Swap.new(@server),
        database = Postgres.new(@server),
        Passenger.new(@server, database, @rails_env, @options),
      ]
    end

    def remote_command(host, command)
      `ssh #{Server.ssh_options} #{host} #{command}`
    end
  end
end

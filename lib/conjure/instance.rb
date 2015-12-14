require "conjure/docker/template"
require "conjure/server"
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
      platform = Server.create "#{@app_name}-#{@rails_env}", @options

      database = Postgres.new(platform)
      database.start

      webserver = Passenger.new(platform, database, @rails_env, @options)
      webserver.start
      passenger_ip = webserver.ip_address

      port = platform.ip_address ? "2222" : "22"
      ip_address = platform.ip_address || passenger_ip

      host = "root@#{ip_address} -p #{port}"

      sleep 1
      remote_command host, "/etc/init.d/nginx restart"
      {
        :ip_address => ip_address,
        :port => port,
        :user => "app",
        :rails_env => @rails_env,
        :pending_files => webserver.pending_files,
      }
    end

    def remote_command(host, command)
      `ssh #{Server.ssh_options} #{host} #{command}`
    end
  end
end

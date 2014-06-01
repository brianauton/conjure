require "conjure/provision/docker/template"
require "conjure/provision/local_docker"
require "conjure/provision/postgres"
require "yaml"

module Conjure
  module Provision
    class Instance
      def initialize(app_name, rails_env)
        @app_name = app_name
        @rails_env = rails_env
      end

      def provision(options = {})
        if options[:local]
          platform = LocalDocker.new
        else
          platform = Server.create "#{@app_name}-#{@rails_env}"
        end

        database = Postgres.new(platform)
        database.start

        webserver = Passenger.new(platform, database, @rails_env)
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
          :rails_env => @rails_env
        }
      end

      def remote_command(host, command)
        `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{host} #{command}`
      end
    end
  end
end

module Conjure
  module Service
    class RailsApplication < Basic
      def initialize(github_url, name = "myapp", environment = "production", config = {})
        @name = name
        @environment = environment
        docker = Service::DockerHost.create "#{name}-#{environment}", config
        postgres = Service::PostgresServer.create docker
        postgres.run
        rails = Service::RailsServer.create docker, github_url, name, postgres.ip_address, environment
        rails.run
        puts "[deploy] Application deployed to #{docker.ip_address}"
      end
    end
  end
end


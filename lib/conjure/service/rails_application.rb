module Conjure
  module Service
    class RailsApplication < Basic
      def initialize(github_url, name = "myapp", environment = "production", config = {})
        @github_url = github_url
        @name = name
        @environment = environment
        @config = config
      end

      def deploy
        postgres = Service::PostgresServer.create docker
        postgres.run
        codebase = Service::RailsCodebase.create docker, @github_url, @name, postgres.ip_address, @environment
        codebase.install
        rails = Service::RailsServer.create docker, @name, @environment
        rails.run
        puts "[deploy] Application deployed to #{docker.ip_address}"
      end

      def docker
        @docker ||= Service::DockerHost.create "#{@name}-#{@environment}", @config
      end

      def database_client
        Service::PostgresClient.create docker, "#{@name}_#{@environment}"
      end
    end
  end
end


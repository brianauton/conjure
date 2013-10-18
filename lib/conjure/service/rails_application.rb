module Conjure
  module Service
    class RailsApplication < Basic
      def initialize(github_url)
        @github_url = github_url
        @name = name_from_github_url github_url
        @environment = "production"
      end

      def deploy
        postgres = Service::PostgresDatabase.create docker, "#{@name}_#{@environment}"
        postgres.run
        codebase = Service::RailsCodebase.create docker, @github_url, @name, postgres.ip_address, @environment
        codebase.install
        rails = Service::RailsServer.create docker, @name, @environment
        rails.run
        puts "[deploy] Application deployed to #{docker.ip_address}"
      end

      def docker
        @docker ||= Service::DockerHost.create "#{@name}-#{@environment}"
      end

      def database_client
        Service::PostgresDatabase.create docker, "#{@name}_#{@environment}"
      end

      def name_from_github_url(github_url)
        github_url.match(/\/([^.]+)\.git$/)[1]
      end
    end
  end
end


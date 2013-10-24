module Conjure
  module Service
    class RailsApplication < Basic
      def initialize(options)
        @github_url = options[:github_url]
        @name = name_from_github_url @github_url
        @branch = options[:branch] || "master"
        @environment = "production"
        @test = options[:test]
      end

      def deploy
        puts "[deploy] Deploying #{@name}:#{@branch} to #{@environment}"
        unless @test
          database.run
          codebase.install
          rails.run
          puts "[deploy] Application deployed to #{docker.ip_address}"
        end
      end

      def docker
        @docker ||= Service::DockerHost.create "#{@name}-#{@environment}"
      end

      def database
        @database ||= Service::PostgresDatabase.create docker, "#{@name}_#{@environment}"
      end

      def codebase
        @codebase ||= Service::RailsCodebase.create docker, @github_url, @branch, @name, database.ip_address, @environment
      end

      def rails
        @rails ||= Service::RailsServer.create docker, @name, @environment
      end

      def name_from_github_url(github_url)
        github_url.match(/\/([^.]+)\.git$/)[1]
      end
    end
  end
end


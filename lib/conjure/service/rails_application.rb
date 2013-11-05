module Conjure
  module Service
    class RailsApplication
      def initialize(options)
        @origin = options[:origin]
        @name = name_from_origin @origin
        @branch = options[:branch] || "master"
        @environment = "production"
        @test = options[:test]
      end

      def deploy
        Conjure.log "[deploy] Deploying #{@name}:#{@branch} to #{@environment}"
        unless @test
          database.run
          codebase.install
          rails.run
          Conjure.log "[deploy] Application deployed to #{docker.ip_address}"
        end
      end

      def docker
        @docker ||= Service::DockerHost.new "#{@name}-#{@environment}"
      end

      def database
        @database ||= Service::PostgresDatabase.new docker, "#{@name}_#{@environment}"
      end

      def codebase
        @codebase ||= Service::RailsCodebase.new docker, @origin, @branch, @name, database.ip_address, @environment
      end

      def rails
        @rails ||= Service::RailsServer.new docker, @name, @environment
      end

      def name_from_origin(origin)
        origin.match(/\/([^.]+)\.git$/)[1]
      end
    end
  end
end


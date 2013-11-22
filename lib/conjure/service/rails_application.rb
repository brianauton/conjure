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
        Log.info "[deploy] Deploying #{@name}:#{@branch} to #{@environment}"
        unless @test
          codebase.install
          rails.run
          Log.info "[deploy] Application deployed to #{docker.ip_address}"
        end
      end

      def docker
        @docker ||= Service::DockerHost.new "#{@name}-#{@environment}"
      end

      def database
        codebase.database
      end

      def codebase
        @codebase ||= Service::RailsCodebase.new docker, @origin, @branch, @name, @environment
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


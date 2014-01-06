module Conjure
  module Service
    class RailsDeployment
      def initialize(options)
        @origin = options[:origin]
        @branch = options[:branch] || "master"
        @environment = "production"
        @test = options[:test]
        @target = options[:target]
      end

      def deploy
        Log.info "[deploy] Deploying #{@branch} to #{@environment}"
        unless @test
          codebase.install
          rails.run
          Log.info "[deploy] Application deployed to #{@target.ip_address}"
        end
      end

      def database
        codebase.database
      end

      def codebase
        @codebase ||= Service::RailsCodebase.new @target, @origin, @branch, @environment
      end

      def rails
        @rails ||= Service::RailsServer.new @target, @environment
      end

      def shell
        rails.base_image
      end
    end
  end
end


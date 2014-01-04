module Conjure
  module Service
    class RailsApplication
      def initialize(options)
        @origin = options[:origin]
        @branch = options[:branch] || "master"
        @environment = "production"
        @test = options[:test]
        @resource_pool = options[:resource_pool]
      end

      def deploy
        Log.info "[deploy] Deploying #{@branch} to #{@environment}"
        unless @test
          codebase.install
          rails.run
          Log.info "[deploy] Application deployed to #{@resource_pool.ip_address}"
        end
      end

      def database
        codebase.database
      end

      def codebase
        @codebase ||= Service::RailsCodebase.new @resource_pool, @origin, @branch, @environment
      end

      def rails
        @rails ||= Service::RailsServer.new @resource_pool, @environment
      end

      def shell
        rails.base_image
      end
    end
  end
end


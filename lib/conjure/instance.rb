module Conjure
  class Instance
    def initialize(options)
      @origin = options[:origin]
      @branch = options[:branch]
      @rails_environment = options[:rails_environment]
      @server = options[:server]
    end

    def self.where(options = {})
      Collection.new(options)
    end

    def origin
      @origin ||= @server.name.split("-")[0]
    end

    def rails_environment
      @rails_environment ||= @server.name.split("-")[1]
    end

    def ip_address
      @server.ip_address
    end

    def shell
      rails_server.base_image
    end

    def branch
      @branch ||= codebase.branch
    end

    def database
      codebase.database
    end

    def deploy
      Log.info "[deploy] Deploying #{branch} to #{rails_environment}"
      codebase.install
      rails_server.run
      Log.info "[deploy] Application deployed to #{ip_address}"
    end

    def codebase
      @codebase ||= Service::RailsCodebase.new target, origin, @branch, rails_environment
    end

    def rails_server
      @rails_server ||= Service::RailsServer.new target, rails_environment
    end

    def server
      @server ||= Service::CloudServer.new("#{application_name}-#{rails_environment}")
    end

    def target
      @target ||= Target.new(:machine_name => server.name)
    end

    def application_name
      Application.new(:origin => @origin).name
    end

    def status
      "running"
    end

    class Collection
      include Enumerable

      def initialize(options)
        @origin = options[:origin]
      end

      def application_name
        Application.new(:origin => @origin).name
      end

      def each(&block)
        return unless @origin
        Service::CloudServer.each_with_name_prefix("#{application_name}-") do |server|
          match = server.name.match(/^#{application_name}-([^-]+)$/)
          yield Instance.new(:server => server) if match
        end
      end
    end
  end
end

module Conjure
  class Instance
    attr_reader :application, :ip_address, :rails_environment

    def initialize(options)
      @application = options[:application]
      @ip_address = options[:ip_address]
      @rails_environment = options[:rails_environment]
    end

    def self.where(options = {})
      Collection.new(options)
    end

    def status
      "running"
    end

    class Collection
      include Enumerable

      def initialize(options)
        @application = options[:application]
      end

      def server
        @server ||= Service::CloudServer.new("#{@application.name}-production") if @application
      end

      def each(&block)
        if server and server.existing_server
          yield Instance.new(
            :application => @application,
            :rails_environment => "production",
            :ip_address => server.ip_address
          )
        end
      end
    end
  end
end

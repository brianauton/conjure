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

      def each(&block)
        return unless @application
        Service::CloudServer.each_with_name_prefix("#{@application.name}-") do |server|
          match = server.name.match(/^#{@application.name}-([^-]+)$/)
          return unless match
          yield Instance.new(
            :application => @application,
            :rails_environment => match[1],
            :ip_address => server.ip_address
          )
        end
      end
    end
  end
end

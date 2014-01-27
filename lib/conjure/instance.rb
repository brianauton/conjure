module Conjure
  class Instance
    attr_reader :origin, :ip_address, :rails_environment

    def initialize(options)
      @origin = options[:origin]
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
        @origin = options[:origin]
      end

      def application_name
        Application.new(:origin => @origin).name
      end

      def each(&block)
        return unless @origin
        Service::CloudServer.each_with_name_prefix("#{application_name}-") do |server|
          match = server.name.match(/^#{application_name}-([^-]+)$/)
          return unless match
          yield Instance.new(
            :origin => @origin,
            :rails_environment => match[1],
            :ip_address => server.ip_address
          )
        end
      end
    end
  end
end

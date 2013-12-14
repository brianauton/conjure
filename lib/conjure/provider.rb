module Conjure
  module Provider
    def self.included(base)
      base.extend ClassMethods
    end

    def self.all(service_type)
      providers(service_type).map{|block| block.call}.flatten.compact
    end

    def self.register_provider(service_type, &block)
      providers(service_type) << block
    end

    def self.providers(service_type)
      @providers ||= {}
      @providers[service_type] ||= []
    end

    module ClassMethods
      def provides(service_type, &block)
        Conjure::Provider.register_provider(service_type, &block)
      end
    end
  end
end

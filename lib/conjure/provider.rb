module Conjure
  module Provider
    def self.included(base)
      base.extend ClassMethods
    end

    def self.all(service_type)
      (@providers && @providers[service_type]) || []
    end

    def self.register_provider(service_type, provider_class)
      @providers ||= {}
      @providers[service_type] ||= []
      @providers[service_type] << provider_class
    end

    module ClassMethods
      def provides(service_type)
        Conjure::Provider.register_provider(service_type, self)
      end
    end
  end
end

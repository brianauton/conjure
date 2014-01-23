require "conjure"

module Conjure
  module View
    class ApplicationView
      def initialize(application)
        @application = application
      end

      def render
        "Running instances: " + (@application.instances.map do |instance|
          "#{instance.rails_environment} at #{instance.ip_address}"
        end.join(", "))
      end
    end
  end
end

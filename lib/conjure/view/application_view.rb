require "conjure"

module Conjure
  module View
    class ApplicationView
      def initialize(application)
        @application = application
      end

      def render
        [application_content, instances_content].join "\n\n"
      end

      private

      def application_content
        content = ["Showing application status (Conjure v#{Conjure::VERSION})"]
        content << "Origin  #{@application.origin}"
        content.join "\n"
      end

      def instances_content
        items = @application.instances.map do |instance|
          "#{instance.rails_environment} at #{instance.ip_address}"
        end
        "Running instances: #{items.join ', '}"
      end
    end
  end
end

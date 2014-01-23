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
        content = ["Deployed Instances:"]
        content += @application.instances.map do |instance|
          "#{instance.ip_address} #{instance.status} #{instance.rails_environment}"
        end
        content << "(none)" unless @application.instances.any?
        content.join "\n"
      end
    end
  end
end

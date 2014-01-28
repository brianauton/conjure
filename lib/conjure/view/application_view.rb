require "conjure"

module Conjure
  module View
    class ApplicationView
      def initialize(application)
        @application = application
        @instances = @application.instances
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
        content << instances_table
        content << "(none)" unless @instances.any?
        content.join "\n"
      end

      def instances_table
        data = @instances.map do |instance|
          {
            "Name" => instance.name,
            "Status" => instance.status,
            "Address" => instance.ip_address,
          }
        end
        TableView.new(data).render
      end
    end
  end
end

module Conjure
  module Provision
    class DockerImage
      attr_reader :image_name

      def initialize(base_image_name)
        @image_name = base_image_name
      end

      def start(shell_command, options = {})
        container_id = `docker run -d #{options[:run_options].to_s} #{image_name} #{shell_command}`.strip
        sleep 2
        ip_address = `docker inspect -format '{{ .NetworkSettings.IPAddress }}' #{container_id}`.strip
        raise "Container failed to start" unless ip_address.present?
        ip_address
      end
    end
  end
end

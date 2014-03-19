module Conjure
  module Provision
    class DockerImage
      attr_reader :image_name

      def initialize(server, base_image_name)
        @server = server
        @image_name = base_image_name
      end

      def start(shell_command, options = {})
        container_id = @server.run("docker run -d #{options[:run_options].to_s} #{image_name} #{shell_command}").strip
        sleep 2
        ip_address = @server.run("docker inspect -format '{{ .NetworkSettings.IPAddress }}' #{container_id}").strip
        raise "Container failed to start" unless ip_address.present?
        ip_address
      end
    end
  end
end

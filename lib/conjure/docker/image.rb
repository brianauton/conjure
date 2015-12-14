module Conjure
  module Docker
    class Image
      attr_reader :image_name

      def initialize(docker_host, image_name)
        @docker_host = docker_host
        @name = image_name
      end

      def start_volume(options = {})
        @docker_host.start @name, "/bin/true", options
      end

      def start_daemon(command, options = {})
        container = @docker_host.start @name, command, options
        sleep 2
        raise "Container failed to start" unless container.ip_address
      end
    end
  end
end

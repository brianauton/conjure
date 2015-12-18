module Conjure
  module Docker
    class Image
      attr_reader :name

      def initialize(docker_host, image_name)
        @docker_host = docker_host
        @name = image_name
      end

      def start_volume(options = {})
        @docker_host.start @name, "/bin/true", options
      end

      def start_daemon(command, options = {})
        @docker_host.start(@name, command, options).tap do |container|
          sleep 2
          raise "Container failed to start" unless container.ip_address
        end
      end
    end
  end
end

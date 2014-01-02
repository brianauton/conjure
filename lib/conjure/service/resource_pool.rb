module Conjure
  module Service
    class ResourcePool
      def initialize(options)
        @machine_name = options[:machine_name]
      end

      def shell
        docker_host.shell
      end

      def ip_address
        docker_host.ip_address
      end

      def docker_host
        @docker_host ||= Service::DockerHost.new @machine_name
      end
    end
  end
end

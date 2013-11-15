module Conjure
  module Service
    class Volume
      def initialize(options)
        @docker_host = options[:docker_host]
        @host_path = options[:host_path]
        @container_path = options[:container_path]
      end

      def read(filename)
        shell.command "cat #{@container_path}/#{filename}"
      end

      def write(filename, data)
        shell.command "echo '#{data}' >#{@container_path}/#{filename}"
      end

      private

      def shell
        @shell ||= @docker_host.images.create(
          :label => "volume",
          :base_image => "ubuntu",
          :host_volumes => {@host_path => @container_path},
        )
      end
    end
  end
end

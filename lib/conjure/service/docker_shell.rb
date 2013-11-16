module Conjure
  module Service
    class DockerShell
      def initialize(options)
        @docker_host = options[:docker_host]
        @image = options[:image]
      end

      def prepare(options)
        self.class.new(
          :docker_host => @docker_host,
          :image => @docker_host.images.create(image_options.merge options),
        )
      end

      def command(*args)
        (@image || default_image).command *args
      end

      def run(*args)
        (@image || default_image).run *args
      end

      def stop(*args)
        (@image || default_image).stop *args
      end

      def image_options
        {
          :base_image => (@image || default_image_name),
          :host_volumes => (@image.host_volumes if @image),
        }
      end

      def default_image
        @default_image ||= @docker_host.images.create(image_options)
      end

      def default_image_name
        "ubuntu"
      end
    end
  end
end

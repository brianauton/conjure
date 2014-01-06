module Conjure
  module Service
    class Volume
      attr_reader :target, :container_path

      def initialize(options)
        @target = options[:target]
        @host_path = options[:host_path]
        @container_path = options[:container_path]
      end

      def read(filename)
        shell.command "cat #{@container_path}/#{filename}"
      end

      def write(filename, data)
        shell.command "echo '#{data}' >#{@container_path}/#{filename}"
      end

      def shell
        @shell ||= @target.shell.prepare(
          :label => "volume",
          :host_volumes => {@host_path => @container_path},
        )
      end
    end
  end
end

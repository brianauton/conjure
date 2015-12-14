require "conjure/docker/container"

module Conjure
  module Docker
    class Host
      def initialize(platform)
        @platform = platform
      end

      def built_image_name(dockerfile_directory)
        result = with_directory(dockerfile_directory) do |remote_dir|
          @platform.run "docker build #{remote_dir}"
        end
        if match = result.match(/Successfully built ([0-9a-z]+)/)
          match[1]
        else
          raise "Failed to build Docker image, output was #{result}"
        end
      end

      def start(image_name, daemon_command, options = {})
        all_options = "#{start_options options} #{image_name} #{daemon_command}"
        Container.new @platform, @platform.run("docker run #{all_options}").strip, options[:name]
      end

      private

      def with_directory(local_path, &block)
        local_archive = remote_archive = "/tmp/archive.tar.gz"
        remote_path = "/tmp/unpacked_archive"
        `cd #{local_path}; tar czf #{local_archive} *`
        @platform.send_file local_archive, remote_archive
        @platform.run "mkdir #{remote_path}; cd #{remote_path}; tar mxzf #{remote_archive}"
        yield remote_path
      ensure
        `rm #{local_archive}`
        @platform.run "rm -Rf #{remote_path} #{remote_archive}"
      end

      def start_options(options)
        [
          "-d",
          "--restart=always",
          mapped_options("--link", options[:linked_containers]),
          ("--name #{options[:name]}" if options[:name]),
          mapped_options("-p", options[:ports]),
          listed_options("--volumes-from", options[:volume_containers]),
        ].flatten.compact.join(" ")
      end

      def listed_options(command, values)
        values ||= []
        values.map { |v| "#{command} #{v}" }
      end

      def mapped_options(command, values)
        values ||= {}
        values.map { |from, to| "#{command} #{from}:#{to}" }
      end
    end
  end
end

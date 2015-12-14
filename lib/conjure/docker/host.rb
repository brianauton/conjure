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

      def started_container_id(image_name, daemon_command, run_options = nil)
        all_options = "#{run_options.to_s} #{image_name} #{daemon_command}"
        @platform.run("docker run #{all_options}").strip
      end

      def container_ip_address(container_id)
        format = "{{ .NetworkSettings.IPAddress }}"
        @platform.run("docker inspect --format '#{format}' #{container_id}").strip
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
    end
  end
end

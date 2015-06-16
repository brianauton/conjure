module Conjure
  module Provision
    module Docker
      class Host
        def initialize(platform)
          @platform = platform
        end

        def built_image_name(dockerfile_directory)
          result = @platform.with_directory(dockerfile_directory) do |remote_dir|
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
      end
    end
  end
end

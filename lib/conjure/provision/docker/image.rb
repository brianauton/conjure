module Conjure
  module Provision
    module Docker
      class Image
        attr_reader :image_name

        def initialize(docker_host, image_name)
          @docker_host = docker_host
          @name = image_name
        end

        def start_volume(options = {})
          @docker_host.started_container_id @name, "/bin/true", daemon_options(options)
        end

        def start_daemon(command, options = {})
          container_id = @docker_host.started_container_id @name, command, daemon_options(options)
          sleep 2
          ip_address = @docker_host.container_ip_address container_id
          raise "Container failed to start" if ip_address.to_s == ""
          ip_address
        end

        private

        def volume_options(options)
          "-d " + run_options(options)
        end

        def daemon_options(options)
          "-d --restart=always " + run_options(options)
        end

        def run_options(options)
          [
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
end

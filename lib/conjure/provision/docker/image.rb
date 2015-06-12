module Conjure
  module Provision
    module Docker
      class Image
        attr_reader :image_name

        def initialize(docker_host, image_name)
          @docker_host = docker_host
          @name = image_name
        end

        def start(command, options = {})
          container_id = @docker_host.started_container_id @name, command, run_options(options)
          sleep 2
          ip_address = @docker_host.container_ip_address container_id
          raise "Container failed to start" unless ip_address.present?
          ip_address
        end

        private

        def run_options(options)
          mapped_options("-p", options[:ports]).join(" ")
        end

        def mapped_options(command, values)
          values ||= {}
          values.map { |from, to| "#{command} #{from}:#{to}" }
        end
      end
    end
  end
end

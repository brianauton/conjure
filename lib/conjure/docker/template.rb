require "conjure/docker/host"
require "tmpdir"

module Conjure
  module Docker
    class Template
      def initialize(base_image_name)
        @commands = ["FROM #{base_image_name}"]
        @file_data = {}
      end

      def add_file(filename, remote_name)
        add_file_data File.read(filename), remote_name
      end

      def add_file_data(data, remote_name)
        local_name = "file#{@file_data.length+1}"
        @file_data[local_name] = data
        @commands << "ADD #{local_name} #{remote_name}"
      end

      def run(command)
        @commands << "RUN #{command}"
      end

      def volume(name)
        @commands << "VOLUME #{name}"
      end

      def source
        @commands.join "\n"
      end

      def start_daemon(server, command, volumes = {}, options = {})
        docker_host = Host.new(server)
        image_name = prepare_build_directory { |dir| docker_host.built_image_name dir }
        volume_containers = volumes.map do |name, path|
          volume_template = Docker::Template.new(image_name)
          volume_template.volume path
          volume_template.start_volume(server, name: name)
          name
        end
        options = options.merge(volume_containers: volume_containers)
        container = docker_host.start(image_name, command, options)
        sleep 2
        raise "Container failed to start" unless container.ip_address
      end

      def start_volume(server, options = {})
        docker_host = Host.new(server)
        image_name = prepare_build_directory { |dir| docker_host.built_image_name dir }
        docker_host.start image_name, "/bin/true", options
      end

      private

      def prepare_build_directory(&block)
        Dir.mktmpdir do |dir|
          @file_data.merge("Dockerfile" => source).each do |filename, data|
            File.write "#{dir}/#{filename}", data
          end
          yield dir
        end
      end
    end
  end
end

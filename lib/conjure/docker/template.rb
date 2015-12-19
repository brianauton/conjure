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

      def start(server, command, options = {})
        docker_host = Host.new(server)
        image_name = prepare_build_directory { |dir| docker_host.built_image_name dir }
        options = options.merge(volume_options(server, image_name, options)) if options[:volumes]
        docker_host.start(image_name, command, options)
      end

      private

      def volume_options(server, image_name, options)
        {
          volume_containers: options[:volumes].map do |name, path|
            volume_template = Docker::Template.new(image_name)
            volume_template.volume path
            volume_template.start(server, "/bin/true", name: name)
            name
          end
        }
      end

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

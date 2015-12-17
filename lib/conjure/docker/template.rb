require "conjure/docker/host"
require "conjure/docker/image"
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

      def start_daemon(server, command, options = {})
        build_image(server).start_daemon(command, options)
      end

      def start_volume(server, options = {})
        build_image(server).start_volume(options)
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

      def build_image(server)
        docker_host = Host.new(server)
        image_name = prepare_build_directory do |dir|
          docker_host.built_image_name dir
        end
        Image.new docker_host, image_name
      end
    end
  end
end

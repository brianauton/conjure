require "conjure/provision/docker_image"

module Conjure
  module Provision
    class Dockerfile
      def initialize(base_image_name, &block)
        @commands = ["FROM #{base_image_name}"]
        @file_data = {}
        instance_eval(&block) if block
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

      def source
        @commands.join "\n"
      end

      def prepare_build_directory(&block)
        Dir.mktmpdir do |dir|
          @file_data.merge("Dockerfile" => source).each do |filename, data|
            File.write "#{dir}/#{filename}", data
          end
          yield dir
        end
      end

      def build(server)
        result = prepare_build_directory do |dir|
          server.with_directory(dir) { |remote_dir| server.run "docker build #{remote_dir}" }
        end
        if match = result.match(/Successfully built ([0-9a-z]+)/)
          DockerImage.new server, match[1]
        else
          raise "Failed to build Docker image, output was #{result}"
        end
      end
    end
  end
end

require "conjure/provision/docker_image"

module Conjure
  module Provision
    class Dockerfile
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

      def upload_build_directory(server, &block)
        archive = "/tmp/dockerfile.tar.gz"
        build_dir = "/tmp/docker_build"
        prepare_build_directory do |dir|
          `cd #{dir}; tar czf #{archive} *`
          server.send_file archive, "dockerfile.tar.gz"
          server.run "mkdir #{build_dir}; cd #{build_dir}; tar mxzf ~/dockerfile.tar.gz"
          result = yield "/tmp/docker_build"
          server.run "rm -Rf #{build_dir} ~/dockerfile.tar.gz"
          `rm #{archive}`
          result
        end
      end

      def build(server)
        result = upload_build_directory(server) { |dir| server.run "docker build #{dir}" }
        if match = result.match(/Successfully built ([0-9a-z]+)/)
          DockerImage.new server, match[1]
        else
          raise "Failed to build Docker image, output was #{result}"
        end
      end
    end
  end
end

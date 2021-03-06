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

      def environment(hash)
        hash.each { |key, value| @commands << "ENV #{key} #{value}" }
      end

      def start(container_host, command, options = {})
        if container_names(options).all? { |name| container_host.running? name }
          puts "Detected all #{options[:name]} containers running."
        else
          puts "Building #{options[:name]} base image..."
          image_name = container_host.build(image_source_files)
          options = options.merge(volume_options(container_host, image_name, options)) if options[:volumes]
          container_host.start(image_name, command, options)
        end
      end

      private

      def container_names(options)
        [options[:name]] + options[:volumes].to_h.keys
      end

      def volume_options(container_host, image_name, options)
        {
          volume_containers: options[:volumes].map do |name, path|
            volume_template = Docker::Template.new(image_name)
            volume_template.volume path
            volume_template.start(container_host, "/bin/true", name: name)
            name
          end
        }
      end

      def image_source_files
        @file_data.merge "Dockerfile" => @commands.join("\n")
      end
    end
  end
end

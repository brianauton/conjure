module Conjure
  module Docker
    class Host
      def initialize(server)
        @server = server
      end

      def start(image_name, daemon_command, options = {})
        container_name = options[:name]
        all_options = "#{start_options options} #{image_name} #{daemon_command}"
        if running? container_name
          puts "Detected #{container_name} container running."
        else
          puts "Starting #{container_name} container..."
          @server.run("docker run #{all_options}").strip
          sleep 2
          raise "Container failed to start" unless running? container_name
        end
      end

      def build(image_source_files)
        Dir.mktmpdir do |dir|
          image_source_files.each { |filename, data| File.write "#{dir}/#{filename}", data }
          result = with_directory(dir) { |remote_dir| @server.run "docker build #{remote_dir}" }
          match = result.match(/Successfully built ([0-9a-z]+)/)
          raise "Failed to build Docker image, output was #{result}" unless match
          match[1]
        end
      end

      def running?(container_name)
        running_container_names.include? container_name
      end

      private

      def with_directory(local_path, &block)
        local_archive = remote_archive = "/tmp/archive.tar.gz"
        remote_path = "/tmp/unpacked_archive"
        `cd #{local_path}; tar czf #{local_archive} *`
        @server.send_file local_archive, remote_archive
        @server.run "mkdir #{remote_path}; cd #{remote_path}; tar mxzf #{remote_archive}"
        yield remote_path
      ensure
        `rm #{local_archive}`
        @server.run "rm -Rf #{remote_path} #{remote_archive}"
      end

      def start_options(options)
        [
          "-d",
          "--restart=always",
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

      def running_container_names
        @server.run("docker ps --format='{{.Names}}'").split("\n").compact
      end
    end
  end
end

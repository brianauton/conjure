require 'digest/sha1'

module Conjure
  module Service
    class DockerHost
      def initialize(server_name)
        @server_name = server_name
      end

      def server
        @server ||= Service::CloudServer.new @server_name
      end

      def ip_address
        @server.ip_address
      end

      def new_docker_path
        Log.info "[docker] Installing docker"
        server.run "dd if=/dev/zero of=/root/swapfile bs=1024 count=524288"
        server.run "mkswap /root/swapfile; swapon /root/swapfile"
        server.run "curl https://get.docker.io/gpg | apt-key add -"
        server.run "echo 'deb https://get.docker.io/ubuntu docker main' >/etc/apt/sources.list.d/docker.list"
        server.run "apt-get update"
        server.run "DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-extra-`uname -r` lxc-docker"
        existing_docker_path
      end

      def existing_docker_path
        path = server.run("which docker").stdout.to_s.strip
        path = nil if path == ""
        Log.info "[docker] Using installed #{path}" if path
        path
      end

      def docker_path
        @docker_path ||= existing_docker_path
        @docker_path ||= new_docker_path
      end

      def command(command, options = {}, &block)
        full_command = "#{docker_path} #{command}"
        full_command = "nohup #{full_command}" if options[:nohup]
        full_command = "echo '#{shell_escape options[:stdin]}' | #{full_command}" if options[:stdin]
        Log.debug "   [scp] #{options[:files].inspect}" if options[:files]
        result = server.run full_command, :stream_stdin => options[:stream_stdin], :files => options[:files], &block
        raise "Docker error: #{result.stdout} #{result.stderr}" unless result.status == 0
        result.stdout
      end

      def ensure_host_directory(dir)
        server.run "mkdir -p #{dir}"
      end

      def shell_escape(text)
        text.gsub "'", "'\"'\"'"
      end

      def images
        ImageSet.new self
      end

      def containers
        ContainerSet.new :host => self
      end

      def shell
        DockerShell.new :docker_host => self
      end
    end

    class ImageSet
      def initialize(host)
        @host = host
      end

      def create(options)
        Image.new @host, options
      end
    end

    class Image
      attr_reader :host_volumes

      def initialize(host, options)
        @host = host
        @label = options[:label]
        @base_image = options[:base_image]
        @ports = options[:ports].to_a
        @volumes = options[:volumes].to_a
        @host_volumes = options[:host_volumes]
        @setup_commands = options[:setup_commands].to_a
        @daemon_command = options[:daemon_command]
        @environment = options[:environment]
        @files = options[:files]
      end

      def image_fingerprint
        Digest::SHA1.hexdigest(dockerfile)[0..11]
      end

      def expected_image_name
        "#{@label}:#{image_fingerprint}"
      end

      def installed_image_name
        build unless image_installed?
        expected_image_name
      end

      def image_installed?
        @host.command("history #{expected_image_name}") rescue false
      end

      def run(command = "")
        unless running_container
          Log.info "[docker] Starting #{@label}"
          run_options = host_volume_options(@host_volumes)
          run_options += port_options(@ports)
          command = shell_command command if command != ""
          container_id = @host.command("run #{run_options.join ' '} -d #{installed_image_name} #{command}").strip
          if(!running_container)
            output = @host.command "logs #{container_id}"
            raise "Docker: #{@label} daemon exited with: #{output}"
          end
        end
        Log.info "[docker] #{@label} is running at #{running_container.ip_address}"
        running_container
      end

      def raise_build_errors(build_output)
        match = build_output.match(/Error build: The command \[([^\]]*)\] returned a non-zero code:/)
        if match
          failed_command = match[1]
          last_section = build_output.split("--->").last
          last_section.gsub!(/Running in [0-9a-f]+/, "")
          last_section.gsub!(/Error build: The command.*/m, "")
          raise "Docker: build step '#{failed_command}' failed: #{last_section.strip}"
        end
      end

      def dockerfile
        lines = ["FROM #{base_image_name}"]
        lines += dockerfile_environment_entries
        lines += @setup_commands.map{|c| "RUN #{c}"}
        lines << "VOLUME #{@volumes.inspect}" if @volumes.to_a.any?
        lines << "ENTRYPOINT #{@daemon_command}" if @daemon_command
        lines.join "\n"
      end

      def dockerfile_environment_entries
        @environment.to_a.map do |k, v|
          "ENV #{k} #{v}" if v.to_s != ""
        end.compact
      end

      def base_image_name
        @base_image.respond_to?(:installed_image_name) ? @base_image.installed_image_name : @base_image
      end

      def build
        destroy_instances
        Log.info "[docker] Building #{@label} image"
        raise_build_errors(@host.command "build -t #{expected_image_name} -", stdin: dockerfile)
        @host.containers.destroy_all_stopped
      end

      def command(command, options = {}, &block)
        destroy_instances
        file_options = options[:files] ? ["-v /files:/files"] : []
        file_options += host_volume_options(@host_volumes)
        file_options << "-i" if options[:stream_stdin]
        @host.command "run #{file_options.join ' '} #{installed_image_name} #{shell_command command}", :stream_stdin => options[:stream_stdin], :files => files_hash(options[:files]), &block
      end

      def host_volume_options(host_volumes)
        host_volumes.to_a.map do |host_path, container_path|
          @host.ensure_host_directory host_path
          "-v=#{host_path}:#{container_path}:rw"
        end
      end

      def port_options(ports)
        ports.to_a.map {|port| "-p=#{port}:#{port}" }
      end

      def files_hash(files_array)
        files_array.to_a.inject({}) do |hash, local_file|
          hash.merge local_file => "/files/#{File.basename local_file}"
        end
      end

      def shell_command(command)
        "bash -c '#{@host.shell_escape command}'"
      end

      def running_container
        @runnning_container ||= @host.containers.find(:image_name => expected_image_name)
      end

      def destroy_instances
        @host.containers.destroy_all :image_name => @label
      end

      def stop
        destroy_instances
      end
    end

    class ContainerSet
      attr_accessor :host

      def initialize(options)
        self.host = options[:host]
      end

      def find(options)
        image_name = options[:image_name].clone
        image_name << ":" unless image_name.include? ":"
        id = host.command("ps | grep #{image_name} ; true").strip.split("\n").first.to_s[0..11]
        id = nil if id == ""
        Container.new(:host => host, :id => id) if id
      end

      def destroy_all_stopped
        all_ids = host.command("ps -a -q").split("\n").map(&:strip)
        running_ids = host.command("ps -q").split("\n").map(&:strip)
        stopped_ids = all_ids - running_ids
        host.command "rm #{stopped_ids.join ' '}"
      end

      def destroy_all(options)
        while container = find(:image_name => options[:image_name]) do
          Log.info "[docker] Stopping #{options[:image_name]}"
          host.command "stop #{container.id}"
          host.command "rm #{container.id}"
        end
      end
    end

    class Container
      attr_accessor :id, :host

      def initialize(options)
        self.id = options[:id]
        self.host = options[:host]
      end

      def ip_address
        status["NetworkSettings"]["IPAddress"]
      end

      def status
        require "json"
        JSON.parse(host.command "inspect #{id}").first
      end
    end
  end
end

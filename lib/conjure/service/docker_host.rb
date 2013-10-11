module Conjure
  module Service
    class DockerHost < Basic
      VERBOSE = false

      def initialize(server_name, config = {})
        @server_name = server_name
        @config = config
      end

      def server
        @server ||= Service::CloudServer.create @server_name, config
      end

      def config
        @config
      end

      def ip_address
        @server.ip_address
      end

      def new_docker_path
        puts "[docker] Installing docker"
        server.run "curl https://get.docker.io/gpg | apt-key add -"
        server.run "echo 'deb https://get.docker.io/ubuntu docker main' >/etc/apt/sources.list.d/docker.list"
        server.run "apt-get update"
        server.run "DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-extra-`uname -r` lxc-docker"
        existing_docker_path
      end

      def existing_docker_path
        path = server.run("which docker").stdout.to_s.strip
        path = nil if path == ""
        puts "[docker] Using installed #{path}" if path
        path
      end

      def docker_path
        @docker_path ||= existing_docker_path
        @docker_path ||= new_docker_path
      end

      def command(command, options = {})
        full_command = "#{docker_path} #{command}"
        full_command = "nohup #{full_command}" if options[:nohup]
        full_command = "echo '#{shell_escape options[:stdin]}' | #{full_command}" if options[:stdin]
        puts "   [ssh] #{full_command}" if VERBOSE
        result = server.run full_command
        raise "Docker error: #{result.stdout} #{result.stderr}" unless result.status == 0
        result.stdout
      end

      def shell_escape(text)
        text.gsub "'", "'\"'\"'"
      end

      def containers
        ContainerSet.new self
      end
    end

    class ContainerSet
      def initialize(host)
        @host = host
      end

      def create(options)
        Container.new @host, options
      end
    end

    class Container
      def initialize(host, options)
        @host = host
        @label = options[:label]
        @base_image = options[:base_image]
        @ports = options[:ports].to_a
        @volumes = options[:volumes].to_a
        @setup_commands = options[:setup_commands].to_a
        @daemon_command = options[:daemon_command]
        @environment = options[:environment]
        @files = options[:files]
      end

      def image_fingerprint
        {base_image: @base_image, setup_commands: @setup_commands}
      end

      def image_name
        hash = Digest::SHA1.hexdigest(image_fingerprint.to_yaml).first(12)
        "#{@label}_#{hash}"
      end

      def run
        unless id
          build
          puts "[docker] Starting #{@label} image"
          container_id = @host.command("run -d #{@label}").strip
          if(!id)
            output = @host.command "logs #{container_id}"
            raise "Docker: #{@label} daemon exited with: #{output}"
          end
        end
        puts "[docker] #{@label} is running at #{ip_address}"
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

      def raise_run_errors(run_output)
      end

      def dockerfile
        lines = ["FROM #{@base_image}"]
        lines += @environment.map{|k, v| "ENV #{k} #{v}"} if @environment
        lines += @setup_commands.map{|c| "RUN #{c}"}
        lines << "EXPOSE #{@ports.map{|p| "#{p}:#{p}"}.join ' '}" if @ports.to_a.any?
        lines << "VOLUME #{@volumes.inspect}" if @volumes.to_a.any?
        lines << "ENTRYPOINT #{@daemon_command}" if @daemon_command
        lines.join "\n"
      end

      def build
        puts "[docker] Building #{@label} image"
        raise_build_errors(@host.command "build -t #{@label} -", stdin: dockerfile)
      end

      def command(command)
        build
        puts "[docker] Executing #{@label} image"
        @host.command "run #{@label} #{command}"
      end

      def shell_command(command)
        "bash -c '#{@host.shell_escape command}'"
      end

      def id
        @id ||= @host.command("ps | grep #{@label}: ; true").strip.split("\n").first.to_s[0..11]
        @id = nil if @id == ""
        @id
      end

      def ip_address
        status["NetworkSettings"]["IPAddress"]
      end

      def status
        require "json"
        JSON.parse(@host.command "inspect #{id}").first
      end
    end
  end
end

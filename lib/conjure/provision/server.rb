require "conjure/digital_ocean/droplet"
require "securerandom"

module Conjure
  module Provision
    class Server
      def initialize(server)
        @server = server
        puts "Configuring droplet..."
        install_swap
      end

      def ip_address
        @server.ip_address
      end

      def run(command)
        `ssh #{ssh_options} root@#{ip_address} '#{shell_escape_single_quotes command}'`
      end

      def send_file(local_name, remote_name)
        `scp #{ssh_options} #{local_name} root@#{ip_address}:#{remote_name}`
      end

      def ssh_options
        "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      end

      def shell_escape_single_quotes(command)
        command.gsub("'", "'\"'\"'")
      end

      def install_swap
        run "dd if=/dev/zero of=/root/swapfile bs=1024 count=524288"
        run "mkswap /root/swapfile; swapon /root/swapfile"
      end

      def self.create(name)
        puts "Creating DigitalOcean droplet..."
        new DigitalOcean::Droplet.new(droplet_options uniquify(name))
      end

      def self.droplet_options(name)
        raise "Error: DIGITALOCEAN_API_TOKEN must be set." unless ENV["DIGITALOCEAN_API_TOKEN"]
        {
          image: "docker",
          key_data: key_data,
          name: name,
          region: "nyc3",
          size: "512mb",
          token: ENV["DIGITALOCEAN_API_TOKEN"],
        }
      end

      def self.key_data
        ssh_dir = File.expand_path "~/.ssh"
        raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(ssh_dir) && File.exist?("#{ssh_dir}/id_rsa.pub")
        File.read "#{ssh_dir}/id_rsa.pub"
      end

      def self.uniquify(server_name)
        "#{server_name}-#{SecureRandom.hex 4}"
      end

      def with_directory(local_path, &block)
        local_archive = remote_archive = "/tmp/archive.tar.gz"
        remote_path = "/tmp/unpacked_archive"
        `cd #{local_path}; tar czf #{local_archive} *`
        send_file local_archive, remote_archive
        run "mkdir #{remote_path}; cd #{remote_path}; tar mxzf #{remote_archive}"
        yield remote_path
      ensure
        `rm #{local_archive}`
        run "rm -Rf #{remote_path} #{remote_archive}"
      end
    end
  end
end

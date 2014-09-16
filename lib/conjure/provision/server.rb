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
        @server.public_ip_address
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
        connection = Fog::Compute.new compute_options
        delete_default_key connection
        new connection.servers.bootstrap(bootstrap_options uniquify(name))
      end

      def self.compute_options
        raise "Error: DIGITALOCEAN_API_KEY and DIGITALOCEAN_CLIENT_ID env vars must both be set." unless ENV["DIGITALOCEAN_API_KEY"] && ENV["DIGITALOCEAN_CLIENT_ID"]
        {
          :provider => :digitalocean,
          :digitalocean_api_key => ENV["DIGITALOCEAN_API_KEY"],
          :digitalocean_client_id => ENV["DIGITALOCEAN_CLIENT_ID"],
        }
      end

      def self.bootstrap_options(name)
        ssh_dir = File.expand_path("~/.ssh")
        raise "Error: ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub must exist." unless File.exist?(ssh_dir) && File.exist?("#{ssh_dir}/id_rsa") && File.exist?("#{ssh_dir}/id_rsa.pub")
        {
          :name => name,
          :flavor_id =>  "66",
          :region_id => "4",
          :image_id => "5900200",
          :private_key_path => "#{ssh_dir}/id_rsa",
          :public_key_path => "#{ssh_dir}/id_rsa.pub",
        }
      end

      def self.delete_default_key(connection)
        connection.ssh_keys.find{|k| k.name=="fog_default"}.try :destroy
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

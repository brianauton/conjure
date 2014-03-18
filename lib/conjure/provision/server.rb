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
        options = "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
        command = "ssh #{options} root@#{ip_address} '#{shell_escape_single_quotes command}'"
        `#{command}`
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
        new connection.servers.bootstrap(bootstrap_options name)
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
          :image_id => "2158507",
          :private_key_path => "#{ssh_dir}/id_rsa",
          :public_key_path => "#{ssh_dir}/id_rsa.pub",
        }
      end
    end
  end
end
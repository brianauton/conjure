require "conjure/digital_ocean/droplet"

module Conjure
  class Server
    def initialize(server)
      @server = server
      install_swap
    end

    def ip_address
      @server.ip_address
    end

    def run(command)
      `ssh #{self.class.ssh_options} root@#{ip_address} '#{shell_escape_single_quotes command}'`
    end

    def send_file(local_name, remote_name)
      `scp #{self.class.ssh_options} #{local_name} root@#{ip_address}:#{remote_name}`
    end

    def self.ssh_options
      "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
    end

    def shell_escape_single_quotes(command)
      command.gsub("'", "'\"'\"'")
    end

    def install_swap
      puts "Installing swap space..."
      run "dd if=/dev/zero of=/root/swapfile bs=4096 count=524288"
      run "mkswap /root/swapfile; swapon /root/swapfile"
    end

    def self.create(name, options = {})
      new DigitalOcean::Droplet.new(droplet_options(name, options))
    end

    def self.droplet_options(name, options = {})
      {
        image: "docker",
        key_data: key_data,
        name_prefix: name,
        region: "nyc3",
        size: (options[:instance_size] || "512mb"),
      }
    end

    def self.key_data
      ssh_dir = File.expand_path "~/.ssh"
      raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(ssh_dir) && File.exist?("#{ssh_dir}/id_rsa.pub")
      File.read "#{ssh_dir}/id_rsa.pub"
    end
  end
end

require "conjure/digital_ocean/droplet"

module Conjure
  class Server
    def initialize(server)
      @server = server
    end

    def ip_address
      @server.ip_address
    end

    def run(command)
      `ssh #{self.class.ssh_options} root@#{ip_address} #{quote_command command}`
    end

    def send_file(local_name, remote_name)
      `scp #{self.class.ssh_options} #{local_name} root@#{ip_address}:#{remote_name}`
    end

    def self.ssh_options
      "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
    end

    def quote_command(command)
      "'" + command.gsub("'", "'\"'\"'") + "'"
    end

    def self.create(name_prefix, options = {})
      new DigitalOcean::Droplet.new(droplet_options(name_prefix, options))
    end

    def self.droplet_options(name_prefix, options = {})
      {
        image: "docker",
        key_data: key_data,
        name_prefix: name_prefix,
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

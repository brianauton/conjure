module Conjure
  module Provision
    class Server
      def initialize(server)
        @server = server
      end

      def ip_address
        @server.public_ip_address
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
        {
          :name => name,
          :flavor_id =>  "66",
          :region_id => "4",
          :image_id => "2158507",
          :private_key_path => "/home/brianauton/.ssh/id_rsa",
          :public_key_path => "/home/brianauton/.ssh/id_rsa.pub",
        }
      end
    end
  end
end

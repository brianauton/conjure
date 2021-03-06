require "conjure/digital_ocean/account"
require "conjure/digital_ocean/key_set"
require "securerandom"

module Conjure
  module DigitalOcean
    class Droplet
      def initialize(options)
        @options = options
        @properties = {}
        create
      end

      def ip_address
        @ip_address ||= begin
          wait_until_ready
          @properties["networks"]["v4"].first["ip_address"]
        end
      end

      private

      def create
        puts "Creating DigitalOcean droplet..."
        response = account.post("droplets", {
          image: @options[:image],
          name: "#{@options[:name_prefix]}-#{SecureRandom.hex 4}",
          region: @options[:region],
          size: @options[:size],
          ssh_keys: [key.id],
        })
        @properties = response["droplet"]
      end

      def wait_until_ready
        while @properties["status"] != "active" do
          sleep 5
          @properties = account.get("droplets/#{@properties['id']}")["droplet"]
        end
        sleep 30
      end

      def account
        raise "Error: DIGITALOCEAN_API_TOKEN must be set." unless ENV["DIGITALOCEAN_API_TOKEN"]
        @account ||= Account.new(:token => ENV["DIGITALOCEAN_API_TOKEN"])
      end

      def key
        KeySet.new(account).find_or_create @options[:key_data]
      end
    end
  end
end

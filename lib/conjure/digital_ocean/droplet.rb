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
        response = account.post("droplets", {
          image: @options[:image],
          name: @options[:name],
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
        sleep 2
      end

      def account
        @account ||= Account.new(:token => @options[:token])
      end

      def key
        KeySet.new(account).find_or_create @options[:key_data]
      end
    end
  end
end

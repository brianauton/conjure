require "json"
require "conjure/http_request"

module Conjure
  module DigitalOcean
    class Account
      def initialize(options)
        @token = options[:token]
      end

      def get(path)
        request path, :method => :get
      end

      def post(path, data = {})
        request path, :method => :post, :data => JSON.unparse(data)
      end

      private

      def request(path, options)
        url = endpoint + path
        options = options.merge :headers => headers
        JSON.parse HttpRequest.new(url, options).data
      end

      def headers
        {
          "Authorization" => "Bearer #{@token}",
          "Content-Type" => "application/json",
        }
      end

      def endpoint
        "https://api.digitalocean.com/v2/"
      end
    end
  end
end

require "net/http"

module Conjure
  class HttpRequest
    def initialize(url, options = {})
      @uri = URI(url)
      @headers = options[:headers] || {}
      @data = options[:data]
      @method = options[:method] || :get
      @ssl = (url.index("https://") == 0)
    end

    def data
      Net::HTTP.start @uri.host, @uri.port, :use_ssl => @ssl do |http|
        http.request(request).body
      end
    end

    private

    def request
      request_class.new(@uri).tap do |object|
        @headers.each { |key, value| object[key] = value }
        object.body = @data if @data
      end
    end

    def request_class
      @method == :post ? Net::HTTP::Post : Net::HTTP::Get
    end
  end
end

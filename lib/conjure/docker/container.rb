module Conjure
  module Docker
    class Container
      attr_reader :name

      def initialize(server, id, name)
        @server = server
        @id = id
        @name = name
      end

      def ip_address
        format = "{{ .NetworkSettings.IPAddress }}"
        address = @server.run("docker inspect --format '#{format}' #{@id}").strip
        address == "" ? nil : address
      end
    end
  end
end

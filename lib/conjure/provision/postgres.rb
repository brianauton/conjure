module Conjure
  module Provision
    class Postgres
      attr_reader :password, :ip_address

      def initialize(server, name)
        @server = server
        @name = name
        @password = new_password
      end

      def start
        @ip_address = dockerfile(password).build(@server).start("/sbin/my_init")
      end

      private

      def dockerfile(db_password)
        Dockerfile.new("conjure/postgres93:1.0.0") do
          run "echo \"ALTER USER db PASSWORD '#{db_password}'\" >/tmp/setpass"
          run "/sbin/my_init -- /sbin/setuser postgres sh -c \"sleep 1; psql -f /tmp/setpass\""
          run "rm /tmp/setpass"
          run "/sbin/my_init -- /sbin/setuser db sh -c \"sleep 1; /usr/bin/createdb #{@name}\""
        end
      end

      def new_password
        require "securerandom"
        SecureRandom.urlsafe_base64 20
      end
    end
  end
end

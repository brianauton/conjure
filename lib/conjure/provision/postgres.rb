module Conjure
  module Provision
    class Postgres
      attr_reader :password, :ip_address

      def initialize(platform, name)
        @platform = platform
        @name = name
        @password = new_password
      end

      def start
        @ip_address = dockerfile(password).build(@platform).start("/sbin/my_init")
      end

      private

      def dockerfile(db_password)
        file = Dockerfile.new("conjure/postgres93:1.0.0")
        file.run "echo \"ALTER USER db PASSWORD '#{db_password}'\" >/tmp/setpass"
        file.run "/sbin/my_init -- /sbin/setuser postgres sh -c \"sleep 1; psql -f /tmp/setpass\""
        file.run "rm /tmp/setpass"
        file.run "/sbin/my_init -- /sbin/setuser db sh -c \"sleep 1; /usr/bin/createdb #{@name}\""
        file
      end

      def new_password
        require "securerandom"
        SecureRandom.urlsafe_base64 20
      end
    end
  end
end

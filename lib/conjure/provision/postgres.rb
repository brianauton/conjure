require "conjure/provision/docker/template"
require "securerandom"

module Conjure
  module Provision
    class Postgres
      def initialize(platform)
        @platform = platform
        @name = "conjure_db_#{SecureRandom.hex 8}"
        @password = new_password
      end

      def start
        @ip_address = dockerfile.build(@platform).start("/sbin/my_init")
      end

      def rails_config
        {
          "adapter" => "postgresql",
          "database" => @name,
          "host" => @ip_address,
          "username" => "db",
          "password" => @password,
          "template" => "template0",
        }
      end

      private

      def dockerfile
        file = Docker::Template.new("conjure/postgres93:1.0.0")
        file.run "echo \"ALTER USER db PASSWORD '#{@password}'\" >/tmp/setpass"
        file.run "/sbin/my_init -- /sbin/setuser postgres sh -c \"sleep 1; psql -f /tmp/setpass\""
        file.run "rm /tmp/setpass"
        file.run "/sbin/my_init -- /sbin/setuser db sh -c \"sleep 1; /usr/bin/createdb #{@name}\""
        file
      end

      def new_password
        SecureRandom.urlsafe_base64 20
      end
    end
  end
end

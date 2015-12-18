require "conjure/docker/template"
require "securerandom"

module Conjure
  class Postgres
    def initialize(server)
      @server = server
      @name = "conjure_db_#{SecureRandom.hex 8}"
      @password = new_password
    end

    def install
      server_template.start_daemon(@server, "/sbin/my_init", start_options)
    end

    def rails_config
      {
        "adapter" => "postgresql",
        "database" => @name,
        "host" => container_name,
        "username" => "db",
        "password" => @password,
        "template" => "template0",
      }
    end

    def container_link
      {container_name => container_name}
    end

    def pending_files
      []
    end

    private

    def start_options
      {
        :name => container_name,
        :volume_containers => [data_container.name],
      }
    end

    def container_name
      "postgres"
    end

    def data_container
      data_template.start_volume(@server, name: "postgres_data")
    end

    def data_template
      file = Docker::Template.new("conjure/postgres93:1.0.0")
      file.volume "/var/lib/postgresql/9.3/main"
      file
    end

    def server_template
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

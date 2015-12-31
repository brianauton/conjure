require "conjure/docker/template"
require "securerandom"

module Conjure
  class Postgres
    def initialize(container_host)
      @container_host = container_host
      @name = "conjure_db_#{SecureRandom.hex 8}"
      @password = new_password
    end

    def install
      server_template.start(@container_host, "/sbin/my_init", start_options)
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
        :volumes => {"postgres_data" => "/var/lib/postgresql/9.3/main"}
      }
    end

    def container_name
      "postgres"
    end

    def server_template
      file = Docker::Template.new("atbaker/sd-postgres")
      file.run "useradd db"
      file.run "/sbin/my_init -- /sbin/setuser postgres sh -c \"sleep 1; psql -h localhost -c 'CREATE USER db CREATEDB'\""
      file.run "/sbin/my_init -- /sbin/setuser db sh -c \"sleep 1; createdb db\""
      file.run "echo 'local all all  ident' >/usr/local/pgsql/data/pg_hba.conf"
      file.run "echo 'host all all 0.0.0.0/0 md5' >>/usr/local/pgsql/data/pg_hba.conf"
      file.run "echo 'host all all ::1/128 md5' >>/usr/local/pgsql/data/pg_hba.conf"
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

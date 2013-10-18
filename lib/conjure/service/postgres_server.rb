module Conjure
  module Service
    class PostgresServer < Basic
      def initialize(host)
        @host = host
        @image = @host.images.create(
          label: "pgserver",
          base_image: postgres_base_image,
          setup_commands: [
            "service postgresql start; su postgres -c 'createuser -d -r -s root; createdb -O root root'; service postgresql stop",
            "echo 'host all all 0.0.0.0/0 trust' >>/etc/postgresql/9.2/main/pg_hba.conf",
            "echo \"listen_addresses='*'\" >>/etc/postgresql/9.2/main/postgresql.conf",
          ],
          daemon_command: "su postgres -c '/usr/lib/postgresql/9.2/bin/postgres -c config_file=/etc/postgresql/9.2/main/postgresql.conf'",
          volumes: ["/var/lib/postgresql/9.2/main"],
        )
      end

      def postgres_base_image
        @host.images.create(
          label: "postgres",
          base_image: "ubuntu",
          setup_commands: [
            "apt-get install -y python-software-properties software-properties-common",
            "add-apt-repository -y ppa:pitti/postgresql",
            "apt-get update",
            "apt-get install -y postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2",
          ],
        )
      end

      def run
        @container = @image.run
      end

      def ip_address
        @container.ip_address
      end
    end
  end
end

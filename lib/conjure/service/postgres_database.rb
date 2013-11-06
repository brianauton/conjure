module Conjure
  module Service
    class PostgresDatabase
      def initialize(host, db_name)
        @host = host
        @db_name = db_name
      end

      def base_image
        @base_image ||= @host.images.create(
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

      def server_image
        @server_image ||= @host.images.create(
          label: "pgserver",
          base_image: base_image,
          setup_commands: [
            "service postgresql start; su postgres -c 'createuser -d -r -s root; createdb -O root root'; service postgresql stop",
            "echo 'host all all 0.0.0.0/0 trust' >>/etc/postgresql/9.2/main/pg_hba.conf",
            "echo \"listen_addresses='*'\" >>/etc/postgresql/9.2/main/postgresql.conf",
          ],
          daemon_command: "su postgres -c '#{bin_path}/postgres -c config_file=/etc/postgresql/9.2/main/postgresql.conf'",
          volumes: ["/var/lib/postgresql/9.2/main"],
        )
      end

      def run
        container
      end

      def container
        @container ||= server_image.run
      end

      def name
        @db_name
      end

      def ip_address
        container.ip_address
      end

      def export(file)
        File.open file, "w" do |f|
          f.write base_image.command("#{bin_path}/pg_dump #{client_options} #{@db_name}")
        end
        Conjure.log "[export] #{File.size file} bytes exported to #{file}"
      end

      def import(file)
        base_image.command "#{bin_path}/psql #{client_options} -d #{@db_name} -f /files/#{File.basename file}", files: [file]
        Conjure.log "[import] #{File.size file} bytes imported from #{file}"
      end

      def client_options
        "-U root -h #{ip_address}"
      end

      def bin_path
        "/usr/lib/postgresql/9.2/bin"
      end
    end
  end
end

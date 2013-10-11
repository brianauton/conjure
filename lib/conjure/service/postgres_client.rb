module Conjure
  module Service
    class PostgresClient < Basic
      def initialize(host, db_name)
        server = PostgresServer.create host
        server.run
        @server_ip = server.ip_address
        @db_name = db_name
        @container = host.containers.create(
          label: "pgclient",
          base_image: "ubuntu",
          setup_commands: [
            "apt-get install -y python-software-properties software-properties-common",
            "add-apt-repository -y ppa:pitti/postgresql",
            "apt-get update",
            "apt-get install -y postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2",
          ],
        )
      end

      def export(file)
        File.open file, "w" do |f|
          f.write @container.command("/usr/lib/postgresql/9.2/bin/pg_dump -U root -h #{@server_ip} #{@db_name}")
        end
      end

      def import(file)
        @container.command "/usr/lib/postgresql/9.2/bin/psql -U root -h #{@server_ip} -d #{@db_name} -f /files/#{File.basename file}", files: [file]
      end
    end
  end
end

module Conjure
  module Service
    class PostgresClient < Basic
      def initialize(host, db_name)
        server = PostgresServer.create host
        server.run
        @server_ip = server.ip_address
        @db_name = db_name
        @image = host.images.create(
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
          f.write @image.command("/usr/lib/postgresql/9.2/bin/pg_dump -U root -h #{@server_ip} #{@db_name}")
        end
        puts "[export] #{File.size file} bytes exported to #{file}"
      end

      def import(file)
        @image.command "/usr/lib/postgresql/9.2/bin/psql -U root -h #{@server_ip} -d #{@db_name} -f /files/#{File.basename file}", files: [file]
        puts "[import] #{File.size file} bytes imported from #{file}"
      end
    end
  end
end

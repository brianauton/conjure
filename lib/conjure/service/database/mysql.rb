module Conjure
  module Service
    class Database
      class Mysql
        def initialize(options)
          @target = options[:target]
          @db_name = options[:database_name]
          @adapter_name = options[:adapter_name]
        end

        def base_image
          @base_image ||= @target.shell.prepare(
            label: "mysql",
            setup_commands: [
              "apt-get install -y mysql-server mysql-client"
            ],
          )
        end

        def server_image
          @server_image ||= base_image.prepare(
            label: "mysqlserver",
            setup_commands: [
              "/usr/sbin/mysqld & sleep 5; echo \"GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION\" | /usr/bin/mysql",
            ],
            daemon_command: "/usr/sbin/mysqld --bind-address=0.0.0.0",
            volumes: ["/var/lib/mysql"],
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
            f.write base_image.command("/usr/bin/mysqldump #{client_options}")
          end
          Log.info "[export] #{File.size file} bytes exported to #{file}"
        end

        def import(file)
          base_image.command "echo 'source /files/#{File.basename file}' | /usr/bin/mysql #{client_options}", files: [file]
          Log.info "[import] #{File.size file} bytes imported from #{file}"
        end

        def client_options
          "-u root -h #{ip_address} #{@db_name}"
        end

        def adapter_name
          @adapter_name || "mysql2"
        end
      end
    end
  end
end

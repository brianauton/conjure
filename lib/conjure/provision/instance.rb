require "conjure/provision/dockerfile"
require "conjure/provision/postgres"

module Conjure
  module Provision
    class Instance
      def initialize(app_name, rails_env)
        @app_name = app_name
        @rails_env = rails_env
      end

      def provision
        server = Server.create "#{@app_name}-#{@rails_env}"

        database = Postgres.new(server, database_name)
        database.start

        passenger_image = passenger_dockerfile(database.ip_address, database.password).build(server)
        passenger_image.start("/sbin/my_init", :run_options => "-p 80:80 -p 2222:22")

        host = "root@#{server.ip_address} -p 2222"
        remote_command host, "/etc/init.d/nginx restart"
        {
          :ip_address => server.ip_address,
          :port => "2222",
          :user => "app",
          :rails_env => @rails_env
        }
      end

      def passenger_dockerfile(db_ip_address, db_password)
        public_key = File.expand_path("~/.ssh/id_rsa.pub")
        raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(public_key)
        file = Dockerfile.new("conjure/passenger-ruby21:1.0.1")
        file.add_file public_key, "/root/.ssh/authorized_keys"
        file.add_file public_key, "/home/app/.ssh/authorized_keys"
        file.run "chown app.app /home/app/.ssh/authorized_keys"
        file.run "chown root.root /root/.ssh/authorized_keys"
        file.add_file_data application_conf, "/etc/nginx/sites-enabled/application.conf"
        file.add_file_data database_yml(db_ip_address, db_password), "/home/app/application/shared/config/database.yml"
        file
      end

      def database_name
        "#{@app_name}_#{@rails_env}"
      end

      def database_yml(db_ip_address, db_password)
        require "yaml"
        {@rails_env => {"adapter" => "postgresql", "database" => database_name, "host" => db_ip_address, "username" => "db", "password" => db_password, "template" => "template0"}}.to_yaml
      end

      def application_conf
        options = {listen: "80", root: "/home/app/application/current/public", passenger_enabled: "on", passenger_user: "app", passenger_ruby: "/usr/bin/ruby2.1", passenger_app_env: @rails_env}
        "server {" + options.map{|k, v| "  #{k} #{v};"}.join("\n") + "}\n"
      end

      def remote_command(host, command)
        `ssh -o StrictHostKeyChecking=no #{host} #{command}`
      end
    end
  end
end

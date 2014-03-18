require "conjure/provision/dockerfile"

module Conjure
  module Provision
    class Instance
      def initialize(rails_env)
        @rails_env = rails_env
      end

      def provision
        db_password = new_db_password
        postgres_image = postgres_dockerfile(db_password).build
        db_ip_address = postgres_image.start("/sbin/my_init")

        passenger_image = passenger_dockerfile(db_ip_address, db_password).build
        ip_address = passenger_image.start("/sbin/my_init", :run_options => "-p 80:80 -p 22:22")

        host = "root@#{ip_address}"
        remote_command host, "/etc/init.d/nginx restart"
        {
          :ip_address => ip_address,
          :port => "22",
          :user => "app",
          :rails_env => @rails_env
        }
      end

      def postgres_dockerfile(db_password)
        file = Dockerfile.new("conjure/postgres93:1.0.0")
        file.run "echo \"ALTER USER db PASSWORD '#{db_password}'\" >/tmp/setpass"
        file.run "/sbin/my_init -- /sbin/setuser postgres sh -c \"sleep 1; psql -f /tmp/setpass\""
        file.run "rm /tmp/setpass"
        file
      end

      def passenger_dockerfile(db_ip_address, db_password)
        config_path = "config/provision/application"
        file = Dockerfile.new("conjure/passenger-ruby21:1.0.0")
        file.add_file "#{config_path}/id_rsa.pub", "/root/.ssh/authorized_keys"
        file.add_file "#{config_path}/id_rsa.pub", "/home/app/.ssh/authorized_keys"
        file.run "chown app.app /home/app/.ssh/authorized_keys"
        file.run "chown root.root /root/.ssh/authorized_keys"
        file.add_file_data application_conf, "/etc/nginx/sites-enabled/application.conf"
        file.add_file_data database_yml(db_ip_address, db_password), "/home/app/application/shared/config/database.yml"
        file
      end

      def new_db_password
        require "securerandom"
        SecureRandom.urlsafe_base64 20
      end

      def database_yml(db_ip_address, db_password)
        require "yaml"
        {@rails_env => {"adapter" => "sqlite3", "database" => "db/#{@rails_env}.sqlite3", "host" => db_ip_address, "username" => "db", "password" => db_password}}.to_yaml
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
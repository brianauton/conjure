require "conjure/provision/docker/template"
require "conjure/provision/local_docker"
require "conjure/provision/postgres"
require "yaml"

module Conjure
  module Provision
    class Instance
      def initialize(app_name, rails_env)
        @app_name = app_name
        @rails_env = rails_env
      end

      def provision(options = {})
        if options[:local]
          platform = LocalDocker.new
        else
          platform = Server.create "#{@app_name}-#{@rails_env}"
        end

        database = Postgres.new(platform)
        database.start

        passenger_image = passenger_dockerfile(database).build(platform)
        passenger_ip = passenger_image.start("/sbin/my_init", :run_options => "-p 80:80 -p 2222:22")
        port = platform.ip_address ? "2222" : "22"
        ip_address = platform.ip_address || passenger_ip

        host = "root@#{ip_address} -p #{port}"

        sleep 1
        remote_command host, "/etc/init.d/nginx restart"
        {
          :ip_address => ip_address,
          :port => port,
          :user => "app",
          :rails_env => @rails_env
        }
      end

      def passenger_dockerfile(database)
        public_key = File.expand_path("~/.ssh/id_rsa.pub")
        raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(public_key)
        file = Docker::Template.new("conjure/passenger-ruby21:1.0.1")
        file.add_file public_key, "/root/.ssh/authorized_keys"
        file.add_file public_key, "/home/app/.ssh/authorized_keys"
        file.run "chown app.app /home/app/.ssh/authorized_keys"
        file.run "chown root.root /root/.ssh/authorized_keys"
        file.add_file_data application_conf, "/etc/nginx/sites-enabled/application.conf"
        file.add_file_data database_yml(database), "/home/app/application/shared/config/database.yml"
        file
      end

      def database_yml(database)
        {@rails_env => database.rails_config}.to_yaml
      end

      def application_conf
        options = {listen: "80", root: "/home/app/application/current/public", passenger_enabled: "on", passenger_user: "app", passenger_ruby: "/usr/bin/ruby2.1", passenger_app_env: @rails_env}
        "server {" + options.map{|k, v| "  #{k} #{v};"}.join("\n") + "}\n"
      end

      def remote_command(host, command)
        `ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{host} #{command}`
      end
    end
  end
end

require "conjure/provision/docker/template"
require "securerandom"

module Conjure
  module Provision
    class Passenger
      attr_reader :ip_address

      def initialize(platform, database, rails_env)
        @platform = platform
        @database = database
        @rails_env = rails_env
      end

      def start 
        @ip_address = dockerfile.build(@platform).start("/sbin/my_init", start_options)
      end

      private

      def start_options
        {:run_options => "-p 80:80 -p 2222:22"}
      end

      def dockerfile
        public_key = File.expand_path("~/.ssh/id_rsa.pub")
        raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(public_key)
        file = Docker::Template.new("conjure/passenger-ruby21:1.0.1")
        file.add_file public_key, "/root/.ssh/authorized_keys"
        file.add_file public_key, "/home/app/.ssh/authorized_keys"
        file.run "chown app.app /home/app/.ssh/authorized_keys"
        file.run "chown root.root /root/.ssh/authorized_keys"
        file.add_file_data nginx_conf, "/etc/nginx/sites-enabled/application.conf"
        file.add_file_data database_yml, "/home/app/application/shared/config/database.yml"
        file.add_file_data secrets_yml, "/home/app/application/shared/config/secrets.yml"
        file
      end

      def database_yml
        {@rails_env => @database.rails_config}.to_yaml
      end

      def secrets_yml
        {@rails_env => {"secret_key_base" => SecureRandom.hex(64)}}.to_yaml
      end

      def nginx_conf
        options = {
          :listen => "80",
          :root => "/home/app/application/current/public",
          :passenger_enabled => "on",
          :passenger_user => "app",
          :passenger_ruby => "/usr/bin/ruby2.1",
          :passenger_app_env => @rails_env,
        }
        "server {" + options.map{|k, v| "  #{k} #{v};"}.join("\n") + "}\n"
      end
    end
  end
end

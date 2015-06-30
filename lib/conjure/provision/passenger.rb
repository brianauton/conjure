require "conjure/provision/docker/template"
require "securerandom"

module Conjure
  module Provision
    class Passenger
      attr_reader :ip_address

      def initialize(platform, database, rails_env, options)
        @platform = platform
        @database = database
        @rails_env = rails_env
        @nginx_directives = options[:nginx_directives] || {}
        @system_packages = options[:system_packages] || []
        @ruby_version = options[:ruby_version] || "2.2"
        @rubygems_version = options[:rubygems_version]
        @use_ssl = !!options[:ssl_hostname]
        @ssl_hostname = options[:ssl_hostname] || "unknown"
      end

      def start 
        @ip_address = server_template.build(@platform).start_daemon("/sbin/my_init", start_options)
      end

      def pending_files
        return [] unless @use_ssl
        [
          "/etc/ssl/certs/application.crt",
          "/etc/ssl/certs/root_and_intermediates.crt",
          "/etc/ssl/private/application.key",
          "/etc/ssl/dhparam.pem",
        ]
      end

      private

      def start_options
        {
          :linked_containers => @database.container_link,
          :name => "passenger",
          :ports => {80 => 80, 443 => 443, 2222 => 22},
          :volume_containers => [data_container_name],
        }
      end

      def data_container_name
        data_template.build(@platform).start_volume(:name => "passenger_data")
        "passenger_data"
      end

      def base_docker_image
        {
          "2.2" => "conjure/passenger-ruby22:1.0.1",
          "2.1" => "conjure/passenger-ruby21:1.0.1",
          "2.0" => "conjure/passenger-ruby20:1.0.1",
          "1.9" => "conjure/passenger-ruby19:1.0.1",
        }[@ruby_version] || raise("Unsupported ruby version #{@ruby_version.inspect}")
      end

      def data_template
        file = Docker::Template.new(base_docker_image)
        file.add_file_data database_yml, "/home/app/application/shared/config/database.yml"
        file.add_file_data secrets_yml, "/home/app/application/shared/config/secrets.yml"
        file.volume "/home/app/application"
        file
      end

      def server_template
        public_key = File.expand_path("~/.ssh/id_rsa.pub")
        raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(public_key)
        file = Docker::Template.new(base_docker_image)
        file.run apt_command if apt_command
        file.run rubygems_command if rubygems_command
        file.add_file public_key, "/root/.ssh/authorized_keys"
        file.add_file public_key, "/home/app/.ssh/authorized_keys"
        file.run "chown app.app /home/app/.ssh/authorized_keys"
        file.run "chown root.root /root/.ssh/authorized_keys"
        file.add_file_data nginx_conf, "/etc/nginx/sites-available/application-no-ssl.conf"
        file.add_file_data nginx_ssl_conf, "/etc/nginx/sites-available/application-ssl.conf"
        which_config = @use_ssl ? "application-ssl" : "application-no-ssl"
        file.run "ln -s /etc/nginx/sites-available/#{which_config}.conf /etc/nginx/sites-enabled/application.conf"
        file
      end

      def apt_command
        if @system_packages.any?
          "apt-get update && apt-get install -y #{@system_packages.join ' '}"
        end
      end

      def rubygems_command
        if @rubygems_version
          target_source = "/usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb"
          "sed -i '23d' #{target_source} && gem update --system #{@rubygems_version}"
        end
      end

      def database_yml
        {@rails_env => @database.rails_config}.to_yaml
      end

      def secrets_yml
        {@rails_env => {"secret_key_base" => SecureRandom.hex(64)}}.to_yaml
      end

      def nginx_conf
        render_template "application-no-ssl.conf"
      end

      def nginx_ssl_conf
        render_template "application-ssl.conf"
      end

      def render_template(name)
        template_path = File.join File.dirname(__FILE__), "templates", "#{name}.erb"
        template_data = File.read template_path
        Erubis::Eruby.new(template_data).result(
          :rails_env => @rails_env,
          :ruby_version => @ruby_version,
          :ssl_hostname => @ssl_hostname,
        )
      end
    end
  end
end

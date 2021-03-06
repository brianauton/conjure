require "conjure/docker/template"
require "erubis"
require "securerandom"

module Conjure
  class Passenger
    def initialize(container_host, options)
      @container_host = container_host
      @database = options[:database]
      @rails_env = options[:rails_env] || "staging"
      @max_upload_mb = options[:max_upload_mb] || 20
      @system_packages = options[:system_packages] || []
      @ruby_version = options[:ruby_version] || "2.2"
      @rubygems_version = options[:rubygems_version]
      @use_ssl = !!options[:ssl_hostname]
      @ssl_hostname = options[:ssl_hostname] || "unknown"
      @services = options[:services] || []
      @system_packages += ["libsqlite3-dev", "libpq-dev"]
      @system_packages += ["libruby#{@ruby_version}", "ruby#{@ruby_version}"]
      @system_packages += @services.flat_map(&:system_packages)
    end

    def install
      server_template.start(@container_host, "/sbin/my_init", start_options)
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
        :volumes => {"passenger_data" => "/home/app/application"},
      }
    end

    def base_docker_image
      {
        "2.2" => "phusion/passenger-ruby22:0.9.18",
        "2.1" => "phusion/passenger-ruby21:0.9.18",
        "2.0" => "phusion/passenger-ruby20:0.9.18",
        "1.9" => "phusion/passenger-ruby19:0.9.18",
      }[@ruby_version] || raise("Unsupported ruby version #{@ruby_version.inspect}")
    end

    def server_template
      public_key = File.expand_path("~/.ssh/id_rsa.pub")
      raise "Error: ~/.ssh/id_rsa.pub must exist." unless File.exist?(public_key)
      file = Docker::Template.new(base_docker_image)
      file.environment HOME: "/root"
      file.run "rm -f /etc/service/nginx/down /etc/nginx/sites-enabled/default"
      file.run "mkdir -p /home/app/application/shared/bundle/ruby/1.9.0/bin"
      file.run "chown -R app /home/app/application && chmod -R 755 /home/app/application"
      file.run "ln -s /usr/bin/node /home/app/application/shared/bundle/ruby/1.9.0/bin/node"
      file.run apt_command if apt_command
      file.run rubygems_command if rubygems_command
      file.run "passwd -u app"
      file.run "rm -f /etc/service/sshd/down"
      file.add_file public_key, "/root/.ssh/authorized_keys"
      file.add_file public_key, "/home/app/.ssh/authorized_keys"
      file.run "chown app.app /home/app/.ssh/authorized_keys"
      file.run "chown root.root /root/.ssh/authorized_keys"
      file.add_file_data nginx_conf, "/etc/nginx/sites-available/application-no-ssl.conf"
      file.add_file_data nginx_ssl_conf, "/etc/nginx/sites-available/application-ssl.conf"
      which_config = @use_ssl ? "application-ssl" : "application-no-ssl"
      file.run "ln -s /etc/nginx/sites-available/#{which_config}.conf /etc/nginx/sites-enabled/application.conf"
      file.add_file_data database_yml, "/home/app/application/shared/config/database.yml"
      file.add_file_data secrets_yml, "/home/app/application/shared/config/secrets.yml"
      @services.each { |service| service.apply(file) }
      file
    end

    def apt_command
      if @system_packages.any?
        "apt-get update && apt-get install -y #{@system_packages.join ' '}"
      end
    end

    def rubygems_command
      if @rubygems_version
        "gem update --system #{@rubygems_version}"
      end
    end

    def database_yml
      {@rails_env.to_s => @database.rails_config}.to_yaml
    end

    def secrets_yml
      {@rails_env.to_s => {"secret_key_base" => SecureRandom.hex(64)}}.to_yaml
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
        :max_upload_mb => @max_upload_mb,
      )
    end
  end
end

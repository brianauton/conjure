module Conjure
  module Service
    class RailsServer
      def initialize(host, app_name, rails_environment)
        @host = host
        @app_name = app_name
        @rails_environment = rails_environment
      end

      def base_image
        @base_image ||= @host.shell.prepare(
          label: "rails_base",
          setup_commands: [
            "apt-get install -y curl git",
            "curl -L https://get.rvm.io | bash -s stable",
            "/usr/local/rvm/bin/rvm install #{ruby_version}",
            "ln -s /usr/local/rvm/rubies/* /usr/local/rvm/default-ruby",
            "bash -c 'source /usr/local/rvm/scripts/rvm; rvm use #{ruby_version}@global --default'",
            "ln -s /usr/local/rvm/rubies/*/lib/ruby/gems/* /usr/local/rvm/gems/default",
            "apt-get install -y #{apt_packages_required_for_gems.join ' '}",
            "echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >>/etc/apt/sources.list",
            "apt-get install -y python-software-properties software-properties-common",
            "add-apt-repository -y ppa:chris-lea/node.js-legacy",
            "apt-get update",
            "apt-get install -y nodejs",

          ],
          environment: {
            PATH:"/usr/local/rvm/gems/default/bin:/usr/local/rvm/default-ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            RAILS_ENV: @rails_environment,
            GITHUB_TOKEN: ENV["GITHUB_TOKEN"],
            FRECKLE_SUBDOMAIN: "neomind",
          },
          host_volumes: {"/rails_app" => "/application_root"},
        )
      end

      def server_image
        @server_image ||= base_image.prepare(
          label: "rails_server",
          ports: [80],
          environment: {
            PATH:"/usr/local/rvm/gems/default/bin:/usr/local/rvm/default-ruby/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          },
        )
      end

      def run
        install_gems
        update_database
        restart_server
      end

      def install_gems
        Log.info "[ rails] Installing gems"
        base_image.command "cd application_root; bundle --deployment"
      end

      def update_database
        database_exists ? migrate_database : initialize_database
      end

      def database_exists
        Log.info "[ rails] Checking the database status"
        base_image.command("cd application_root; bundle exec rake db:version; true").include? "Current version:"
      end

      def migrate_database
        Log.info "[ rails] Migrating the database"
        base_image.command "cd application_root; bundle exec rake db:migrate"
      end

      def initialize_database
        Log.info "[ rails] Setting up the database"
        base_image.command "cd application_root; bundle exec rake db:setup"
      end

      def restart_server
        server_image.stop
        server_image.run "cd application_root; rm -f tmp/pids/server.pid; bundle exec rails server -p 80"
      end

      def log(options = {})
        arguments = []
        arguments << "-n #{options[:lines]}" if options[:lines]
        arguments << "-f" if options[:tail]
        log_file = "application_root/log/#{@rails_environment}.log"
        base_image.command "tail #{arguments.join ' '} #{log_file}" do |stdout, stderr|
          puts stdout
        end
      rescue Interrupt => e
      end

      def rake(command)
        base_image.command "cd application_root; bundle exec rake #{command}" do |stdout, stderr|
          print stdout
        end
      end

      def console
        base_image.command "cd application_root; bundle exec rails console", :stream_stdin => true do |stdout, stderr|
          print stdout
        end
      end

      def ruby_version
        Conjure.config.file_contents("../.ruby-version").strip
      end

      def apt_packages_required_for_gems
        ["libpq-dev", "libmysqlclient-dev"]
      end
    end
  end
end

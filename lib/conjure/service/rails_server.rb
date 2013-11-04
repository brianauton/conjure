module Conjure
  module Service
    class RailsServer < Basic
      def initialize(host, app_name, rails_environment)
        @host = host
        @app_name = app_name
        @rails_environment = rails_environment
      end

      def base_image
        @base_image ||= @host.images.create(
          label: "rails_base",
          base_image: "ubuntu",
          setup_commands: [
            "apt-get install -y curl git",
            "curl -L https://get.rvm.io | bash -s stable",
            "rvm install #{ruby_version}",
            "bash -c 'source /usr/local/rvm/scripts/rvm; rvm use #{ruby_version}@global --default'",
            "apt-get install -y #{apt_packages_required_for_gems.join ' '}",
            "echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >>/etc/apt/sources.list",
            "apt-get install -y python-software-properties software-properties-common",
            "add-apt-repository -y ppa:chris-lea/node.js-legacy",
            "apt-get update",
            "apt-get install -y nodejs",

          ],
          environment: {
            PATH:"/usr/local/rvm/gems/ruby-1.9.3-p448@global/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            RAILS_ENV: @rails_environment,
            GITHUB_TOKEN: ENV["GITHUB_TOKEN"],
            FRECKLE_SUBDOMAIN: "neomind",
          },
          host_volumes: {"/rails_app" => "/#{@app_name}"},
        )
      end

      def server_image
        @server_image ||= @host.images.create(
          label: "rails_server",
          base_image: base_image,
          ports: [80],
          environment: {
            PATH:"/usr/local/rvm/gems/ruby-1.9.3-p448@global/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
          },
          host_volumes: {"/rails_app" => "/#{@app_name}"},
        )
      end

      def run
        install_gems
        update_database
        restart_server
      end

      def install_gems
        Conjure.log "[ rails] Installing gems"
        base_image.command "cd #{@app_name}; bundle --deployment"
      end

      def update_database
        database_exists ? migrate_database : initialize_database
      end

      def database_exists
        Conjure.log "[ rails] Checking the database status"
        base_image.command("cd #{@app_name}; bundle exec rake db:version; true").include? "Current version:"
      end

      def migrate_database
        Conjure.log "[ rails] Migrating the database"
        base_image.command "cd #{@app_name}; bundle exec rake db:migrate"
      end

      def initialize_database
        Conjure.log "[ rails] Setting up the database"
        base_image.command "cd #{@app_name}; bundle exec rake db:setup"
      end

      def restart_server
        server_image.stop
        server_image.run "cd #{@app_name}; rm -f tmp/pids/server.pid; bundle exec rails server -p 80"
      end

      def log(options = {})
        arguments = []
        arguments << "-n #{options[:lines]}" if options[:lines]
        arguments << "-f" if options[:tail]
        log_file = "#{@app_name}/log/#{@rails_environment}.log"
        base_image.command "tail #{arguments.join ' '} #{log_file}" do |stdout, stderr|
          puts stdout
        end
      rescue Interrupt => e
      end

      def rake(command)
        base_image.command "cd #{@app_name}; bundle exec rake #{command}" do |stdout, stderr|
          print stdout
        end
      end

      def console
        base_image.command "cd #{@app_name}; bundle exec rails console", :stream_stdin => true do |stdout, stderr|
          print stdout
        end
      end

      def ruby_version
        Conjure.config.file_contents("../.ruby-version").strip
      end

      def apt_packages_required_for_gems
        ["libpq-dev"]
      end
    end
  end
end

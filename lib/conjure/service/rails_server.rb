module Conjure
  module Service
    class RailsServer < Basic
      def initialize(host, app_name, rails_environment = "production")
        @app_name = app_name
        config = host.config
        ruby_version = file_contents(config, "../.ruby-version").strip
        @container = host.containers.create(
          label: "rails",
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
            RAILS_ENV: rails_environment,
            GITHUB_TOKEN: ENV["GITHUB_TOKEN"],
            FRECKLE_SUBDOMAIN: "neomind",
          },
          ports: [80],
          host_volumes: {"/rails_app" => "/#{@app_name}"},
        )
      end

      def run
        @container.command "cd #{@app_name}; bundle --deployment"
        @container.command "cd #{@app_name}; bundle exec rake db:setup"
        @container.run "cd #{@app_name}; bundle exec rails server -p 80"
      end

      def apt_packages_required_for_gems
        ["libpq-dev"]
      end
    end
  end
end

module Conjure
  module Service
    class RailsServer < Basic
      def initialize(host, github_url, app_name, database_ip_address, rails_environment = "production")
        config = host.config
        ruby_version = file_contents(config, "../.ruby-version").strip
        github_private_key = file_contents(config, config.private_key_file).gsub("\n", "\\n")
        github_public_key = file_contents(config, config.public_key_file).gsub("\n", "\\n")
        @container = host.containers.create(
          label: "rails",
          base_image: "ubuntu",
          setup_commands: [
           "apt-get install -y curl git",
            "curl -L https://get.rvm.io | bash -s stable",
            "rvm install #{ruby_version}",
            "bash -c 'source /usr/local/rvm/scripts/rvm; rvm use #{ruby_version}@global --default'",
            "mkdir -p /root/.ssh; echo '#{github_private_key}' > /root/.ssh/id_rsa",
            "mkdir -p /root/.ssh; echo '#{github_public_key}' > /root/.ssh/id_rsa.pub",
            "chmod -R go-rwx /root/.ssh",
            "echo 'Host github.com\\n\\tStrictHostKeyChecking no\\n' >> /root/.ssh/config",
            "git clone #{github_url}",
            "apt-get install -y #{apt_packages_required_for_gems.join ' '}",
            "cd #{app_name}; bundle --deployment",

            "echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >>/etc/apt/sources.list",
            "apt-get install -y python-software-properties software-properties-common",
            "add-apt-repository -y ppa:chris-lea/node.js-legacy",
            "apt-get update",
            "apt-get install -y nodejs",

            "echo '#{database_yml database_ip_address, app_name, rails_environment}' >/#{app_name}/config/database.yml",
            "cd #{app_name}; bundle exec rake db:setup",
          ],
          environment: {
            PATH:"/usr/local/rvm/gems/ruby-1.9.3-p448@global/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            RAILS_ENV: rails_environment,
            GITHUB_TOKEN: ENV["GITHUB_TOKEN"],
            FRECKLE_SUBDOMAIN: "neomind",
          },
          daemon_command: "cd #{app_name}; bundle exec rails server -p 80",
          ports: [80],
          volumes: ["/#{app_name}/log"],
        )
      end

      def run
        @container.run
      end

      def database_yml(database_ip_address, app_name, rails_environment)
        {
          rails_environment => {
            "adapter" => "postgresql",
            "database" => "#{app_name}_#{rails_environment}",
            "encoding" => "utf8",
            "host" => database_ip_address,
            "username" => "root",
            "template" => "template0",
          }
        }.to_yaml.gsub("\n", "\\n")
      end

      def apt_packages_required_for_gems
        ["libpq-dev"]
      end
    end
  end
end

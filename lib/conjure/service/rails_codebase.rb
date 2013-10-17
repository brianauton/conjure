module Conjure
  module Service
    class RailsCodebase < Basic
      def initialize(host, github_url, app_name, database_ip_address, rails_environment = "production")
        @github_url = github_url
        @app_name = app_name
        @database_ip_address = database_ip_address
        @rails_environment = rails_environment
        config = host.config
        github_private_key = file_contents(config, config.private_key_file).gsub("\n", "\\n")
        github_public_key = file_contents(config, config.public_key_file).gsub("\n", "\\n")
        @container = host.containers.create(
          label: "codebase",
          base_image: "ubuntu",
          setup_commands: [
            "apt-get install -y git",
            "mkdir -p /root/.ssh; echo '#{github_private_key}' > /root/.ssh/id_rsa",
            "mkdir -p /root/.ssh; echo '#{github_public_key}' > /root/.ssh/id_rsa.pub",
            "chmod -R go-rwx /root/.ssh",
            "echo 'Host github.com\\n\\tStrictHostKeyChecking no\\n' >> /root/.ssh/config",
          ],
          host_volumes: {"/rails_app" => "/#{app_name}"},
        )
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
        }.to_yaml
      end

      def install
        @container.command "if [ ! -d #{@app_name}/.git ]; then git clone #{@github_url}; fi"
        @container.command "echo '#{database_yml @database_ip_address, @app_name, @rails_environment}' >/#{@app_name}/config/database.yml"
      end

      def container_id
        @container.id
      end
    end
  end
end

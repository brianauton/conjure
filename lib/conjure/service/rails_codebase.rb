module Conjure
  module Service
    class RailsCodebase < Basic
      def initialize(host, github_url, app_name, database_ip_address, rails_environment)
        @github_url = github_url
        @app_name = app_name
        @database_ip_address = database_ip_address
        @rails_environment = rails_environment
        github_private_key = file_contents(Conjure.config.private_key_file).gsub("\n", "\\n")
        github_public_key = file_contents(Conjure.config.public_key_file).gsub("\n", "\\n")
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

      def database_yml
        {
          @rails_environment => {
            "adapter" => "postgresql",
            "database" => "#{@app_name}_#{@rails_environment}",
            "encoding" => "utf8",
            "host" => @database_ip_address,
            "username" => "root",
            "template" => "template0",
          }
        }.to_yaml
      end

      def install
        puts "[  repo] Checking out code from git"
        @container.command "if [ ! -d #{@app_name}/.git ]; then git clone #{@github_url}; fi"
        puts "[  repo] Generating database.yml"
        @container.command "echo '#{database_yml}' >/#{@app_name}/config/database.yml"
      end
    end
  end
end

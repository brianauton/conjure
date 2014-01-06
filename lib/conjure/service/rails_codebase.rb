module Conjure
  module Service
    class RailsCodebase
      def initialize(target, github_url, branch, rails_environment)
        @github_url = github_url
        @branch = branch
        @rails_environment = rails_environment
        @target = target
      end

      def database_yml
        {
          @rails_environment => {
            "adapter" => database.adapter_name,
            "database" => database.name,
            "encoding" => "utf8",
            "host" => database.ip_address,
            "username" => "root",
            "template" => "template0",
          }
        }.to_yaml
      end

      def install
        repository_link.update
        configure_database
        configure_logs
      end

      def repository_link
        @repository_link ||= RepositoryLink.new(
          :volume => volume,
          :branch => @branch,
          :origin_url => @github_url,
          :public_key => Conjure.identity.public_key_data.gsub("\n", "\\n"),
        )
      end

      def volume
        @volume ||= Volume.new(:target => @target, :host_path => "/rails_app", :container_path => "/application_root")
      end

      def configure_database
        Log.info "[  repo] Generating database.yml"
        volume.write "config/database.yml", database_yml
      end

      def configure_logs
        Log.info "[  repo] Configuring application logger"
        setup = 'Rails.logger = Logger.new "#{Rails.root}/log/#{Rails.env}.log"'
        volume.write "config/initializers/z_conjure_logger.rb", setup
      end

      def gem_names
        volume.read("Gemfile").scan(/gem ['"]([^'"]+)['"]/).flatten
      end

      def database
        @database ||= Database.new :target => @target, :codebase => self
      end
    end
  end
end

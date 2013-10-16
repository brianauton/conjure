require "thor"

module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      application.deploy
    end

    desc "import FILE", "Imports the production database from a postgres SQL dump"
    def import(file)
      application.database_client.import file
    end

    desc "export FILE", "Exports the production database to a postgres SQL dump"
    def export(file)
      application.database_client.export file
    end

    default_task :help

    private

    def application
      Service::RailsApplication.create github_url, app_name, rails_environment, config(Dir.pwd)
    end

    def rails_environment
      "production"
    end

    def docker_host
      Service::DockerHost.create "#{app_name}-#{rails_environment}", config(Dir.pwd)
    end

    def config(source_path)
      require "ostruct"
      config_path = File.join source_path, "config", "conjure.yml"
      data = YAML.load_file config_path
      data["config_path"] = File.dirname config_path
      OpenStruct.new data
    end

    def app_name
      name_from_github_url github_url
    end

    def github_url
      git_origin_url Dir.pwd
    end

    def git_origin_url(source_path)
      remote_info = `cd #{source_path}; git remote -v |grep origin`
      remote_info.match(/(git@github.com[^ ]+)/)[1]
    end

    def name_from_github_url(github_url)
      github_url.match(/\/([^.]+)\.git$/)[1]
    end
  end
end

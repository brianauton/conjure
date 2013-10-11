module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      Service::RailsApplication.create github_url, app_name, "production", config(Dir.pwd)
    end

    desc "export FILE", "Exports the production database to a postgres SQL dump"
    def export(file)
      environment = "production"
      host = Service::DockerHost.create "#{app_name}-#{environment}", config(Dir.pwd)
      Service::PostgresClient.create(host, "#{app_name}_#{environment}").export file
      puts "[export] #{File.size file} bytes exported to #{file}"
    end

    default_task :help

    private

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

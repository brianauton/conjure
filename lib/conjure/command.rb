module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      Service::RailsApplication.create github_url, app_name, "production", config(Dir.pwd)
      github_url = git_origin_url Dir.pwd
      app_name = name_from_github_url github_url
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

    def git_origin_url(source_path)
      remote_info = `cd #{source_path}; git remote -v |grep origin`
      remote_info.match(/(git@github.com[^ ]+)/)[1]
    end

    def name_from_github_url(github_url)
      github_url.match(/\/([^.]+)\.git$/)[1]
    end
  end
end

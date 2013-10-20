require "thor"

module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      application.deploy
    end

    desc "import FILE", "Imports the production database from a postgres SQL dump"
    def import(file)
      application.database.import file
    end

    desc "export FILE", "Exports the production database to a postgres SQL dump"
    def export(file)
      application.database.export file
    end

    desc "log", "Show the Rails log from the deployed server"
    def log
      application.rails.log
    end

    default_task :help

    private

    def application
      Service::RailsApplication.create github_url
    end

    def github_url
      git_origin_url Dir.pwd
    end

    def git_origin_url(source_path)
      remote_info = `cd #{source_path}; git remote -v |grep origin`
      remote_info.match(/(git@github.com[^ ]+)/)[1]
    end
  end
end

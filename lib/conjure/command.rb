require "thor"

module Conjure
  class Command < Thor
    desc "deploy", "Deploy the app"
    def deploy
      application.deploy
    end

    desc "import FILE", "Import the production database from a postgres SQL dump"
    def import(file)
      application.database.import file
    end

    desc "export FILE", "Export the production database to a postgres SQL dump"
    def export(file)
      application.database.export file
    end

    desc "log", "Display the Rails log from the deployed application"
    method_option :num, :aliases => "-n", :type => :numeric, :default => 10, :desc => "Show N lines of output"
    method_option :tail, :aliases => "-t", :type => :boolean, :desc => "Continue streaming new log entries"
    def log
      application.rails.log :lines => options[:num], :tail => options[:tail]
    end

    desc "rake [ARGUMENTS...]", "Run the specified rake task on the deployed application"
    def rake(*arguments)
      application.rails.rake arguments.join(" ")
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

require "thor"

module Conjure
  class Command < Thor
    attr_accessor :application_options

    class_option :verbose, :aliases => "-v", :type => :boolean, :desc => "Show details of low-level operations for debugging"
    def initialize(*args)
      super
      Log.level = :debug if options[:verbose]
    end

    desc "deploy", "Deploy the app"
    method_option :branch, :aliases => "-b", :type => :string, :desc => "Specify branch to deploy"
    method_option :test, :type => :boolean, :desc => "Describe the deploy settings but don't deploy"
    method_option :origin, :type => :string, :desc => "Specify git URL to deploy from"
    def deploy
      self.application_options = {
        :branch => options[:branch],
        :test => options[:test],
        :origin => options[:origin],
      }
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
      task = arguments.join(" ")
      Service::RakeTask.new(:task => task, :shell => application.shell) do |stdout|
        print stdout
      end
    end

    desc "console", "Start a console on the deployed application"
    def console
      Service::RailsConsole.new(:shell => application.shell) do |stdout|
        print stdout
      end
    end

    default_task :help

    private

    def application
      self.application_options ||= {}
      self.application_options[:origin] ||= github_url
      self.application_options[:resource_pool] = resource_pool
      Service::RailsApplication.new self.application_options
    end

    def resource_pool
      application_name = self.application_options[:origin].match(/\/([^.]+)\.git$/)[1]
      machine_name = "#{application_name}-production"
      Service::ResourcePool.new(:machine_name => machine_name)
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

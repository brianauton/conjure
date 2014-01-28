require "thor"

module Conjure
  class Command < Thor
    class_option :verbose, :aliases => "-v", :type => :boolean, :desc => "Show details of low-level operations for debugging"
    def initialize(*args)
      super
      Log.level = :debug if options[:verbose]
    end

    desc "create", "Create and deploy a new instance of the application"
    method_option :branch, :aliases => "-b", :type => :string, :desc => "Specify branch to deploy, default 'master'"
    method_option :origin, :type => :string, :desc => "Specify git URL to deploy from"
    method_option :rails_env, :type => :string, :desc => "Specify the Rails environment, default 'production'"
    def create
      target.new_instance.deploy
    end

    desc "deploy", "Deploy the app"
    method_option :branch, :aliases => "-b", :type => :string, :desc => "Specify branch to deploy, default 'master'"
    method_option :origin, :type => :string, :desc => "Specify git URL to deploy from"
    method_option :rails_env, :type => :string, :desc => "Specify the Rails environment, default 'production'"
    def deploy
      (target.existing_instance || target.new_instance).deploy
    end

    desc "import FILE", "Import the production database from a postgres SQL dump"
    def import(file)
      target.existing_instance.database.import file
    end

    desc "export FILE", "Export the production database to a postgres SQL dump"
    def export(file)
      target.existing_instance.database.export file
    end

    desc "log", "Display the Rails log from the deployed application"
    method_option :num, :aliases => "-n", :type => :numeric, :default => 10, :desc => "Show N lines of output"
    method_option :tail, :aliases => "-t", :type => :boolean, :desc => "Continue streaming new log entries"
    def log
      Service::RailsLogView.new(:shell => target.existing_instance.shell, :rails_env => target.existing_instance.rails_env, :lines => options[:num], :tail => options[:tail]) do |stdout|
        print stdout
      end
    end

    desc "rake [ARGUMENTS...]", "Run the specified rake task on the deployed application"
    def rake(*arguments)
      task = arguments.join(" ")
      Service::RakeTask.new(:task => task, :shell => target.existing_instance.shell) do |stdout|
        print stdout
      end
    end

    desc "console", "Start a console on the deployed application"
    def console
      Service::RailsConsole.new(:shell => target.existing_instance.shell) do |stdout|
        print stdout
      end
    end

    desc "show", "Show info on deployed instances"
    def show
      puts View::ApplicationView.new(target.application).render
    end

    default_task :help

    private

    def target
      CommandTarget.new(options)
    end
  end
end

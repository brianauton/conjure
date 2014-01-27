require "thor"

module Conjure
  class Command < Thor
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
      deployment.deploy
    end

    desc "import FILE", "Import the production database from a postgres SQL dump"
    def import(file)
      command_subject.instance.database.import file
    end

    desc "export FILE", "Export the production database to a postgres SQL dump"
    def export(file)
      command_subject.instance.database.export file
    end

    desc "log", "Display the Rails log from the deployed application"
    method_option :num, :aliases => "-n", :type => :numeric, :default => 10, :desc => "Show N lines of output"
    method_option :tail, :aliases => "-t", :type => :boolean, :desc => "Continue streaming new log entries"
    def log
      Service::RailsLogView.new(:shell => command_subject.instance.shell, :lines => options[:num], :tail => options[:tail]) do |stdout|
        print stdout
      end
    end

    desc "rake [ARGUMENTS...]", "Run the specified rake task on the deployed application"
    def rake(*arguments)
      task = arguments.join(" ")
      Service::RakeTask.new(:task => task, :shell => command_subject.instance.shell) do |stdout|
        print stdout
      end
    end

    desc "console", "Start a console on the deployed application"
    def console
      Service::RailsConsole.new(:shell => command_subject.instance.shell) do |stdout|
        print stdout
      end
    end

    desc "show", "Show info on deployed instances"
    def show
      puts View::ApplicationView.new(command_subject.application).render
    end

    default_task :help

    private

    def deployment
      @deployment ||= Service::RailsDeployment.new({
        :branch => options[:branch],
        :origin => command_subject.application.origin,
        :target => target,
        :test => options[:test],
      })
    end

    def target
      Target.new(:machine_name => "#{command_subject.application.name}-production")
    end

    def command_subject
      CommandSubject.new(options)
    end
  end
end

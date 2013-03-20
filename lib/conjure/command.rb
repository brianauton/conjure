module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      instance = Service::MachineInstance.new
      codebase = Codebase.new source_path
      server = Service::RailsServer.new instance
      codebase.deploy_to instance
      server.start
    end
    default_task :deploy
  end
end


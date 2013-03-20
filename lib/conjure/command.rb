module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      instance = Service::MachineInstance.new
      source_tree = Service::SourceTree.new source_path, instance
      server = Service::RailsServer.new source_tree, instance
      server.start
    end
    default_task :deploy
  end
end


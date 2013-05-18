module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      Service::RailsApplication.create source_path
    end
    default_task :deploy
  end
end


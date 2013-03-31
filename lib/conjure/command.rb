module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      app = Service::RailsApplication.new source_path
      app.start
    end
    default_task :deploy
  end
end


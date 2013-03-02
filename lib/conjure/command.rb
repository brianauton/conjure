module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      instance = Instance.new
      codebase = Codebase.new source_path
      rails = Service::Rails.new
      codebase.deploy_to instance
      rails.install_to instance
      rails.start_server
    end
    default_task :deploy
  end
end


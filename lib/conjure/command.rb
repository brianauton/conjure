module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy(source_path = Dir.pwd)
      instance = Instance.new
      codebase = Codebase.new source_path
      codebase.deploy_to instance
    end
    default_task :deploy
  end
end


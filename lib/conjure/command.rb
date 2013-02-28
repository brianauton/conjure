module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      Codebase.new.deploy_to Instance.new
    end
    default_task :deploy
  end
end


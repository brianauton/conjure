module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      Instance.new
    end
    default_task :deploy
  end
end


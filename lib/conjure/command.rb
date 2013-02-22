module Conjure
  class Command < Thor
    desc "deploy", "Deploys the app"
    def deploy
      puts "deploying..."
    end
    default_task :deploy
  end
end


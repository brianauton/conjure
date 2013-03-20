module Conjure
  module Service
    class RailsServer
      def initialize(instance)
        @working_dir = "codebase"
        @instance = instance
      end

      def installed?
        shell("bundle check").include? "dependencies are satisfied"
      end

      def install
        puts "Installing additional system packages..."
        shell "sudo apt-get -y install curl libyaml-dev build-essential libsqlite3-dev nodejs"

        puts "Installing rvm..."
        shell "curl -L https://get.rvm.io | bash -s -- --ignore-dotfiles"
        shell "echo \"source $HOME/.rvm/scripts/rvm\" >> ~/.bash_profile"
        shell "source $HOME/.rvm/scripts/rvm"

        puts "Installing ruby..."
        shell "rvm install 1.9.3"
        shell "rvm use 1.9.3@codebase --create --default"

        puts "Installing gems..."
        shell "bundle"
      end

      def start
        @instance.start
        install unless installed?
        puts "Starting rails server..."
        if shell("rails server -d").include? "application starting"
          puts "The app is running at http://localhost:4000/"
        else
          puts "The rails server failed to start."
        end
      end

      def shell(command)
        command = "cd #{@working_dir}; #{command}" if @working_dir
        command.gsub! "'", "'\\\\''"
        command = "bash --login -c '#{command}' 2>&1"
        @instance.remote_command_output command
      end
    end
  end
end

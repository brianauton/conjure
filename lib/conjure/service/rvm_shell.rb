module Conjure
  module Service
    class RvmShell < Basic
      def initialize(machine_instance, ruby_version, gemset)
        @instance = machine_instance
        @ruby_version = ruby_version
        @gemset = gemset
      end

      def start
        shell "sudo apt-get -y install curl libyaml-dev build-essential libsqlite3-dev nodejs"
        shell "curl -L https://get.rvm.io | bash -s -- --ignore-dotfiles"
        shell "echo \"source $HOME/.rvm/scripts/rvm\" >> ~/.bash_profile"
        shell "source $HOME/.rvm/scripts/rvm"
        shell "rvm install #{@ruby_version}"
        shell "rvm use #{@ruby_version}@#{@gemset} --create --default"
      end

      def execute(command)
        command.gsub! "'", "'\\\\''"
        command = "bash --login -c '#{command}' 2>&1"
        @instance.remote_command_output command
      end
    end
  end
end

module Conjure
  module Service
    class RailsServer < Basic
      def initialize(source_tree, instance)
        @working_dir = "codebase"
        @instance = instance
        @source_tree = source_tree
        @rvm_shell = Service::RvmShell.new instance, "1.9.3", "codebase"
      end

      def dependencies
        [@instance, @source_tree, @rvm_shell]
      end

      def started?
        shell("bundle check").include? "dependencies are satisfied"
      end

      def start
        dependencies.each &:start
        return if started?
        puts "Installing gems..."
        execute "cd codebase; bundle"
        puts "Starting rails server..."
        if execute("rails server -d").include? "application starting"
          puts "The app is running at http://localhost:4000/"
        else
          puts "The rails server failed to start."
        end
      end

      def execute(command)
        command = "cd #{@working_dir}; #{command}" if @working_dir
        @rvm_shell.execute command
      end
    end
  end
end

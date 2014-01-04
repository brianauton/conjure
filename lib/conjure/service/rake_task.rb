module Conjure
  module Service
    class RakeTask
      def initialize(options, &block)
        task = options[:task]
        shell = options[:shell]
        shell.command("cd application_root; bundle exec rake #{task}", &block)
      end
    end
  end
end

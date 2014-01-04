module Conjure
  module Service
    class RailsConsole
      def initialize(options, &block)
        shell = options[:shell]
        shell.command("cd application_root; bundle exec rails console", :stream_stdin => true, &block)
      end
    end
  end
end

module Conjure
  module Service
    class RailsLogView
      def initialize(options, &block)
        arguments = []
        arguments << "-n #{options[:lines]}" if options[:lines]
        arguments << "-f" if options[:tail]
        arguments << "application_root/log/production.log"
        options[:shell].command("tail #{arguments.join ' '}", &block)
      rescue Interrupt
      end
    end
  end
end

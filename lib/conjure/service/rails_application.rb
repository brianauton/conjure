module Conjure
  module Service
    class RailsApplication
      def initialize(source_path)
        @source_path = source_path
      end

      def start
        instance = Service::MachineInstance.new
        source_tree = Service::SourceTree.new @source_path, instance
        server = Service::RailsServer.new source_tree, instance
        server.start
      end
    end
  end
end


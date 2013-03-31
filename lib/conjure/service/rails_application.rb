module Conjure
  module Service
    class RailsApplication < Basic
      def initialize(source_path)
        source_path = source_path
        @instance = Service::MachineInstance.new
        @source_tree = Service::SourceTree.new source_path, @instance
        @server = Service::RailsServer.new @source_tree, @instance
      end

      def dependencies
        [@instance, @source_tree, @server]
      end
    end
  end
end


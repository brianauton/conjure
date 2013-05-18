module Conjure
  module Service
    autoload :RailsApplication, "conjure/service/rails_application"
    autoload :RailsServer, "conjure/service/rails_server"
    autoload :RvmShell, "conjure/service/rvm_shell"
    autoload :MachineInstance, "conjure/service/machine_instance"
    autoload :SourceTree, "conjure/service/source_tree"
  end

  class Basic
    def dependencies
      []
    end

    def started?
      false
    end

    def start
    end

    def save
      dependencies.each &:start
      start unless started?
    end

    def self.create(*args)
      new(*args).save
    end
  end
end

module Conjure
  module Service
    autoload :RailsApplication, "conjure/service/rails_application"
    autoload :RailsServer, "conjure/service/rails_server"
    autoload :RvmShell, "conjure/service/rvm_shell"
    autoload :MachineInstance, "conjure/service/machine_instance"
    autoload :SourceTree, "conjure/service/source_tree"
  end
end

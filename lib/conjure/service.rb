module Conjure
  module Service
    autoload :RailsApplication, "conjure/service/rails_application"
    autoload :RailsServer, "conjure/service/rails_server"
    autoload :MachineInstance, "conjure/service/machine_instance"
    autoload :DockerHost, "conjure/service/docker_host"
    autoload :CloudServer, "conjure/service/cloud_server"
    autoload :PostgresServer, "conjure/service/postgres_server"
  end

  class Basic
    def self.create(*args)
      new(*args)
    end
  end
end

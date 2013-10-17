module Conjure
  module Service
    autoload :RailsApplication, "conjure/service/rails_application"
    autoload :RailsCodebase, "conjure/service/rails_codebase"
    autoload :RailsServer, "conjure/service/rails_server"
    autoload :MachineInstance, "conjure/service/machine_instance"
    autoload :DockerHost, "conjure/service/docker_host"
    autoload :CloudServer, "conjure/service/cloud_server"
    autoload :PostgresServer, "conjure/service/postgres_server"
    autoload :PostgresClient, "conjure/service/postgres_client"
  end

  class Basic
    def self.create(*args)
      new(*args)
    end

    def file_contents(file_path)
      file_path = File.join Conjure.config.config_path, file_path
      `cat #{file_path}`
    end
  end
end

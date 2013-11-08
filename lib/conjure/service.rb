module Conjure
  module Service
    autoload :RailsApplication, "conjure/service/rails_application"
    autoload :RailsCodebase, "conjure/service/rails_codebase"
    autoload :RailsServer, "conjure/service/rails_server"
    autoload :DockerHost, "conjure/service/docker_host"
    autoload :CloudServer, "conjure/service/cloud_server"
    autoload :PostgresDatabase, "conjure/service/postgres_database"
    autoload :RemoteShell, "conjure/service/remote_shell"
  end
end

require "conjure/postgres"
require "conjure/passenger"

module Conjure
  class RailsApplication
    def initialize(server, options)
      @server = server
      @options = options
    end

    def install
      components.each(&:install)
    end

    def pending_files
      components.flat_map(&:pending_files)
    end

    private

    def components
      [
        database = Postgres.new(@server),
        Passenger.new(@server, @options.merge(database: database)),
      ]
    end
  end
end

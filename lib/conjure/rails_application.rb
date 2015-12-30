require "conjure/delayed_job"
require "conjure/postgres"
require "conjure/passenger"

module Conjure
  class RailsApplication
    def initialize(container_host, options)
      @container_host = container_host
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
        database = Postgres.new(@container_host),
        Passenger.new(@container_host, @options.merge(
          database: database,
          services: [DelayedJob.new(@options)],
        )),
      ]
    end
  end
end

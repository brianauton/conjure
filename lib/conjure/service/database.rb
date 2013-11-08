module Conjure
  module Service
    class Database
      def self.new(options)
        Postgres.new :docker_host => options[:docker_host], :database_name => options[:database_name]
      end
    end
  end
end

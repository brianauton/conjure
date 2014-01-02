module Conjure
  module Service
    class Database
      def self.new(options)
        services_by_gem.each do |gem_name, service_class|
          if options[:codebase].gem_names.include? gem_name
            return service_class.new(
              :docker_host => options[:docker_host],
              :database_name => "rails_app_db",
              :adapter_name => adapters_by_gem[gem_name],
            )
          end
        end
      end

      def self.services_by_gem
        {"pg" => Postgres, "mysql2" => Mysql, "mysql" => Mysql}
      end

      def self.adapters_by_gem
        {"pg" => "postgresql", "mysql2" => "mysql2", "mysql" => "mysql"}
      end
    end
  end
end

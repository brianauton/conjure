module Conjure
  class CommandTarget
    def initialize(options = {})
      @origin = options[:origin]
      @branch = options[:branch] || "master"
      @rails_env = options[:rails_env] || "production"
    end

    def application
      @application ||= Application.find(:path => Dir.pwd, :origin => @origin)
    end

    def existing_instance
      @existing_instance ||= application.instances.first
    end

    def new_instance
      @new_instance ||= Instance.new(
        :origin => application.origin,
        :branch => @branch,
        :rails_environment => @rails_env,
      )
    end
  end
end

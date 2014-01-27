module Conjure
  class CommandSubject
    def initialize(options = {})
      @origin = options[:origin]
    end

    def application
      @application ||= Application.find(:path => Dir.pwd, :origin => @origin)
    end

    def instance
      @instance ||= application.instances.first
    end
  end
end

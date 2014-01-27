module Conjure
  class CommandSubject
    def initialize(options = {})
      @origin = options[:origin]
    end

    def application
      @application ||= Application.find(:path => Dir.pwd, :origin => @origin)
    end
  end
end

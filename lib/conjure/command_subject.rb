module Conjure
  class CommandSubject
    def initialize(options = {})
      @origin = options[:origin]
      @test = options[:test]
    end

    def application
      @application ||= Application.find(:path => Dir.pwd, :origin => @origin)
    end

    def instance
      @instance ||= application.instances.first.tap do |instance|
        instance.test = true if @test && instance
      end
    end
  end
end

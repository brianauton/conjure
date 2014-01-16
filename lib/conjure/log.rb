module Conjure
  class Log
    class << self
      attr_accessor :level
      attr_accessor :capture
      attr_reader :history
    end

    def self.info(message)
      if @capture
        @history ||= ""
        @history << "#{message}\n"
      else
        puts message
      end
    end

    def self.debug(message)
      info message if @level == :debug
    end
  end
end

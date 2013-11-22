module Conjure
  class Log
    class << self
      attr_accessor :level
    end

    def self.info(message)
      puts message
    end

    def self.debug(message)
      puts message if @level == :debug
    end
  end
end

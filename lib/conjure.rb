module Conjure

  VERSION = "0.1.0" unless defined?(VERSION)
  autoload :Command, "conjure/command"
  autoload :Config, "conjure/config"
  autoload :Service, "conjure/service"

  def self.config
    @config ||= Config.load Dir.pwd
  end

  def self.log(message)
    puts message
  end
end

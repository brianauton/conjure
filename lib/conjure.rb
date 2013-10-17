module Conjure

  VERSION = "0.0.2" unless defined?(VERSION)
  autoload :Command, "conjure/command"
  autoload :Config, "conjure/config"
  autoload :Service, "conjure/service"

  def self.config
    @config ||= Config.load Dir.pwd
  end
end

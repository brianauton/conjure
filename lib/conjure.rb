module Conjure

  VERSION = "0.0.0" unless defined?(VERSION)
  autoload :Command, "conjure/command"
  autoload :Service, "conjure/service"

end

module Conjure

  VERSION = "0.0.0" unless defined?(VERSION)
  autoload :Command, "conjure/command"
  autoload :Instance, "conjure/instance"

end

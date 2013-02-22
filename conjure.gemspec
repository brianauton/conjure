require File.expand_path("../lib/conjure", __FILE__)

Gem::Specification.new do |s|
  s.name = "conjure"
  s.version = Conjure::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Brian Auton"]
  s.email = ["brianauton+conjure@gmail.com"]
  s.homepage = "http://github.com/brianauton/conjure"
  s.summary = "Deploy like magic"
  s.description = "Deploy like magic"
  s.required_rubygems_version = ">= 1.3.6"
  s.require_path = "lib"
  s.executables = ["conjure"]
  s.add_dependency "thor"
  s.add_dependency "vagrant"
end


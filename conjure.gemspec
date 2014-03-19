require File.expand_path("../lib/conjure/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "conjure"
  s.version = Conjure::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Brian Auton"]
  s.email = ["brianauton@gmail.com"]
  s.homepage = "http://github.com/brianauton/conjure"
  s.summary = "Magically powerful deployment for Rails applications"
  s.license = "MIT"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = Dir.glob("lib/**/*") + ["README.md", "History.md", "License.txt"]
  s.require_path = "lib"
  s.executables = ["conjure"]
  s.add_dependency "fog", ">= 1.19.0"
  s.add_dependency "thor"
  s.add_dependency "unf"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rspec", ">= 3.0.0.beta2"
  s.add_development_dependency "rake"
end


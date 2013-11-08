module Conjure

  VERSION = "0.1.2" unless defined?(VERSION)
  Dir[File.join(File.dirname(__FILE__), "conjure/**/*.rb")].each { |f| require f }

  def self.config
    @config ||= Config.load Dir.pwd
  end

  def self.log(message)
    puts message
  end
end

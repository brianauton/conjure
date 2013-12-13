module Conjure
  require File.join(File.dirname(__FILE__), "conjure/provider")
  Dir[File.join(File.dirname(__FILE__), "conjure/**/*.rb")].each { |f| require f }

  def self.config
    @config ||= Config.load Dir.pwd
  end
end

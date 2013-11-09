module Conjure
  Dir[File.join(File.dirname(__FILE__), "conjure/**/*.rb")].each { |f| require f }

  def self.config
    @config ||= Config.load Dir.pwd
  end

  def self.log(message)
    puts message
  end
end

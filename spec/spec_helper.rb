RSpec.configure do |config|
  config.before(:each) do
    require "conjure"
    Conjure::Log.capture = true
    Conjure::Log.clear
    ENV["THOR_DEBUG"] = "1"
  end
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    require "conjure"
    Conjure::Log.capture = true
    Conjure::Log.clear
    ENV["THOR_DEBUG"] = "1"
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Conjure::Log.capture = true
    Conjure::Log.clear
  end
end

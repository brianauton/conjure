require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/data/vcr"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<DIGITALOCEAN_API_TOKEN>") { ENV["DIGITALOCEAN_API_TOKEN"] }
end

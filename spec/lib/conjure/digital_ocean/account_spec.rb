require "conjure/digital_ocean/account"

module Conjure
  module DigitalOcean
    describe Account, :vcr do
      before do
        @account = Account.new :token => ENV["DIGITALOCEAN_API_TOKEN"]
      end

      describe "#get" do
        it "completes a GET request to the DigitalOcean API" do
          result = @account.get "/regions"
          expect(result["regions"]).to include a_hash_including "name" => "New York 1"
        end
      end

      describe "#post" do
        it "completes a POST request to the DigitalOcean API" do
          result = @account.post "/account/keys", :name => "bogus"
          expect(result).to include "message" => "Key can't be blank"
        end
      end
    end
  end
end

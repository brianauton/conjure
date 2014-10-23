require "conjure/digital_ocean/key"
require "digest/sha1"

module Conjure
  module DigitalOcean
    class KeySet
      def initialize(account)
        @account = account
      end

      def find_or_create(data)
        find(data) || create(data)
      end

      private

      def keys
        @account.get("account/keys")["ssh_keys"].map { |data| Key.new data }
      end        

      def find(data)
        keys.select { |key| key.public_key.strip == data.strip }.first
      end

      def create(data)
        name = "conjure_" + Digest::SHA1.hexdigest(data).slice(0, 8)
        Key.new @account.post("account/keys", :name => name, :public_key => data)["ssh_key"]
      end
    end
  end
end

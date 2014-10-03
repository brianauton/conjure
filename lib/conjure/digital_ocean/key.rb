module Conjure
  module DigitalOcean
    class Key
      attr_reader :id, :public_key

      def initialize(data)
        @id = data["id"]
        @public_key = data["public_key"]
      end
    end
  end
end

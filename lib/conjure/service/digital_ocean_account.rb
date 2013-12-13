module Conjure
  module Service
    class DigitalOceanAccount
      def compute_options
        {
          :provider => :digitalocean,
          :digitalocean_api_key => Conjure.config.digitalocean_api_key,
          :digitalocean_client_id => Conjure.config.digitalocean_client_id,
        }
      end

      def bootstrap_options
        {
          :flavor_name => "512MB",
          :region_name => (Conjure.config.digitalocean_region || "New York 1"),
          :image_name => "Ubuntu 13.04 x64",
        }
      end
    end
  end
end

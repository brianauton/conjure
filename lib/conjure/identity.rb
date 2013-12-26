module Conjure
  class Identity
    require "digest/md5"

    def initialize(config)
      @config = config
    end

    def private_key_path
      Pathname.new(@config.config_path).join @config.private_key_file
    end

    def public_key_path
      Pathname.new(@config.config_path).join @config.public_key_file
    end

    def public_key_data
      File.open(public_key_path, "rb") { |file| file.read }
    end

    def unique_identifier
      "conjure_#{Digest::MD5.hexdigest(public_key_data)[0..7]}"
    end
  end
end

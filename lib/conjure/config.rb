module Conjure
  class Config
    def self.load(root_path)
      require "ostruct"
      config_path = File.join root_path, "config", "conjure.yml"
      data = YAML.load_file config_path
      data["config_path"] = File.dirname config_path
      OpenStruct.new data
    end
  end
end

module Conjure
  class Config
    def self.load(root_path)
      require "ostruct"
      config_path = File.join root_path, "config", "conjure.yml"
      data = YAML.load_file config_path
      data["config_path"] = File.dirname config_path
      new data
    end

    def initialize(options)
      @options = options
    end

    def method_missing(name)
      return @options[name.to_s] if @options.has_key? name.to_s
      super
    end

    def file_contents(name)
      name = @options[name.to_s] if name.is_a? Symbol
      File.open File.join(@options["config_path"], name), "rb", &:read
    end
  end
end

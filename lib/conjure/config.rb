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
      find_default_keys unless @options["private_key"]
    end

    def method_missing(name)
      return @options[name.to_s] if @options.has_key? name.to_s
      super
    end

    def file_contents(name)
      name = @options[name.to_s] if name.is_a? Symbol
      name = File.join(@options["config_path"], name) unless name[0] == "/"
      File.open name, "rb", &:read
    end

    private

    def find_default_keys
      private_key_paths = ["~/.ssh/id_rsa", "~/.ssh/id_dsa", "~/.ssh/identity"]
      private_key_paths.each do |path|
        path = File.expand_path(path)
        if File.exists?(path) and File.exists?("#{path}.pub")
          @options["private_key_file"] = path
          @options["public_key_file"] = "#{path}.pub"
          return
        end
      end
    end
  end
end

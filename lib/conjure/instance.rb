require "vagrant"

module Conjure
  class Instance
    def initialize
      config_path = File.expand_path "../../../config", __FILE__
      @vagrant = Vagrant::Environment.new :cwd => config_path
      install_base_image
      puts "Initialized."
    end

    def install_base_image
      unless @vagrant.boxes.find "precise64"
        puts "Downloading 300MB Ubuntu base image for Vagrant, this may take a few minutes..."
        @vagrant.boxes.add "precise64", "http://files.vagrantup.com/precise64.box"
      end
    end
  end
end

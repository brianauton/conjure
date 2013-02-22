require "vagrant"

module Conjure
  class Instance
    def initialize
      @vagrant = Vagrant::Environment.new
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

require "vagrant"

module Conjure
  class Instance
    def initialize
      config_path = File.expand_path "../../../config", __FILE__
      @vagrant = Vagrant::Environment.new :cwd => config_path
      install_base_image
      start_vm
      issue_test_command
    end

    def install_base_image
      unless @vagrant.boxes.find "precise64"
        puts "Downloading 300MB Ubuntu base image for Vagrant, this may take a few minutes..."
        @vagrant.boxes.add "precise64", "http://files.vagrantup.com/precise64.box"
      end
    end

    def start_vm
      unless @vagrant.primary_vm.state == :running
        puts "Starting a VM..."
        @vagrant.primary_vm.up
      end
    end

    def issue_test_command
      puts "Sending the VM a command..."
      @vagrant.primary_vm.channel.execute "uname -mrs" do |device, data|
        puts "OS info reported by the VM: #{data}"
      end
    end
  end
end

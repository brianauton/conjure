require "vagrant"

module Conjure
  class Instance
    def initialize
      @config_path = File.expand_path "../../../config", __FILE__
      load_environment
      install_base_image
      @vm = @vagrant.primary_vm
      start_vm
      issue_test_command
    end

    def load_environment
      @vagrant = Vagrant::Environment.new :cwd => @config_path
    end

    def install_base_image
      unless @vagrant.boxes.find "precise64"
        puts "Downloading 300MB Ubuntu base image for Vagrant, this may take a few minutes..."
        @vagrant.boxes.add "precise64", "http://files.vagrantup.com/precise64.box"
        load_environment
      end
    end

    def start_vm
      unless @vm.state == :running
        puts "Starting a VM..."
        @vm.up
      end
    end

    def ssh_address
      info = @vm.ssh.info
      "#{info[:username]}@#{info[:host]}"
    end

    def ssh_options
      info = @vm.ssh.info
      "-p #{info[:port]} -i #{info[:private_key_path]}"
    end

    def remote_command_output(command)
      command.gsub! "'", "'\\\\''"
      `ssh #{ssh_address} #{ssh_options} '#{command}'`
    end

    def issue_test_command
      puts "OS info reported by the VM: #{remote_command_output 'uname -mrs'}"
    end
  end
end

module Conjure
  module Service
    class SourceTree < Basic
      def initialize(source_path, machine_instance)
        @source_path = source_path
        @instance = machine_instance
      end

      def copy_to(instance, dest_path)
        options = "-a -e \"ssh #{instance.ssh_options}\""
        source = "#{@source_path}/"
        dest = "#{instance.ssh_address}:#{dest_path}"
        system "rsync #{options} #{source} #{dest}"
      end

      def start(dest_path="codebase")
        puts "Transferring source code..."
        copy_to @instance, dest_path
        size = "#{@instance.remote_command_output "du -hs #{dest_path}"}"
        size = size.split(/\s/).first
        puts "Installed codebase size is #{size}."
      end
    end
  end
end

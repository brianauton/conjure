module Conjure
  module Service
    class RemoteShell
      require "net/ssh"

      def initialize(options)
        @options = options
      end
    
      def run(command)
        stdout, stderr, exit_status = ["", "", nil]
        connection.open_channel do |channel|
          channel.request_pty
          channel.exec command do |c, success|
            raise "Failed to execute command via SSH" unless success
            channel.on_data do |c, data|
              yield data if block_given?
              stdout << data
            end
            channel.on_extended_data { |c, type, data| stderr << data }
            channel.on_request("exit-status") { |c, data| exit_status = data.read_long }
          end
        end
        connection.loop
        Result.new stdout, stderr, exit_status
      end
      
      def connection
        connection_options = {
          :auth_methods => ["publickey"],
          :key_data => File.read(@options[:private_key_path]),
          :keys_only => true,
        }
        @connection ||= Net::SSH.start(@options[:ip_address], @options[:username], connection_options)
      end
    end

    Result = Struct.new(:stdout, :stderr, :status)
  end
end

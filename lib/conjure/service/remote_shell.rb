module Conjure
  module Service
    class RemoteShell
      require "net/ssh"

      class << self
        attr_accessor :ssh_service
      end
      @ssh_service = Net::SSH

      def initialize(options = {})
        @options = options
      end
    
      def run(command, options = {}, &block)
        Log.debug "   [ssh] #{command}"
        result = nil
        session.open_channel do |channel|
          channel.request_pty
          channel.exec command do |c, success|
            raise "Failed to execute command via SSH" unless success
            result = Result.new(channel, &block)
          end
          if options[:stream_stdin]
            channel.on_process do
              poll_stream(STDIN) { |data| channel.send_data data }
            end
          end
        end
        if options[:stream_stdin]
          with_raw_tty { session.loop 0.01 }
        else
          session.loop
        end
        result
      end

      def session
        session_options = {
          :auth_methods => ["publickey"],
          :paranoid => false,
          :forward_agent => true,
        }
        @session ||= self.class.ssh_service.start @options[:ip_address], @options[:username], session_options
      end

      def poll_stream(stream, &block)
        yield stream.sysread(1) if IO.select([stream], nil, nil, 0.01)
      end

      def with_raw_tty
        system "stty raw -echo"
        yield
      ensure
        system "stty -raw echo"
      end

      class Result
        attr_accessor :stdout, :stderr, :status
        def initialize(channel)
          @stdout, @stderr = "", ""
          channel.on_data do |c, data|
            yield data if block_given?
            @stdout << data
          end
          channel.on_extended_data { |c, type, data| @stderr << data }
          channel.on_request("exit-status") { |c, data| @status = data.read_long }
        end
      end
    end

  end
end

module Mock
  class NetSsh
    class << self
      attr_reader :last_session, :loop_callback
    end

    def initialize(options)
      @options = options
    end

    def self.reset
      @last_session = @loop_callback = nil
    end

    def self.on_loop(&block)
      @loop_callback = block
    end

    def self.start(ip_address, username, options)
      @last_session = Session.new(ip_address, username, options, @loop_callback)
    end

    class Session
      attr_reader :ip_address, :username, :command_history

      def initialize(ip_address, username, options, loop_callback)
        @ip_address = ip_address
        @username = username
        @command_history = []
        @loop_callback = loop_callback
        @channels = []
      end

      def open_channel(&block)
        channel = Channel.new(@command_history)
        @channels << channel
        yield channel
      end

      def loop(*args)
        @channels.each {|c| c.instance_eval &@loop_callback} if @loop_callback
      end
    end

    class Channel
      def initialize(command_history)
        @command_history = command_history
      end

      def exec(command)
        @command_history << command
        yield self, true
      end

      def on_data(&block)
        @data_callback = block
      end

      def on_extended_data(&block)
        @extended_data_callback = block
      end

      def on_request(type, &block)
        @exit_status_callback = block if type == "exit-status"
      end

      def send_output(data)
        @data_callback.call(self, data) if @data_callback
      end

      def send_error(data)
        @extended_data_callback.call(self, :error, data) if @extended_data_callback
      end

      def send_exit_status(data)
        @exit_status_callback.call(self, Result.new(data)) if @exit_status_callback
      end

      def request_pty
      end
    end

    class Result
      def initialize(data)
        @data = data
      end

      def read_long
        @data.to_i
      end
    end
  end
end

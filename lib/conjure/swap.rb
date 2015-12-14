module Conjure
  class Swap
    def initialize(server)
      @server = server
    end

    def install
      puts "Installing swap space..."
      @server.run "dd if=/dev/zero of=/root/swapfile bs=4096 count=524288"
      @server.run "mkswap /root/swapfile; swapon /root/swapfile"
    end
  end
end

module Conjure
  class Swap
    def initialize(server)
      @server = server
    end

    def install
      if exists?
        puts "Swap space detected."
      else
        puts "Swap space not detected, installing..."
        @server.run "dd if=/dev/zero of=/root/swapfile bs=4096 count=524288"
        @server.run "mkswap /root/swapfile; swapon /root/swapfile"
        puts "Swap space installed."
      end
    end

    private

    def exists?
      @server.run("swapon -s | wc -l").to_i > 1
    end
  end
end

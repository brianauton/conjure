module Conjure
  class Firewall
    def initialize(server)
      @server = server
    end

    def install
      if exists?
        puts "Firewall detected."
      else
        puts "Firewall not detected, installing..."
        open_ports.each { |port| @server.run "ufw allow #{port}/tcp" }
        @server.run "ufw --force enable"
        puts "Firewall installed."
      end
    end

    def pending_files
      []
    end

    private

    def open_ports
      [22, 80, 443, 2222]
    end

    def exists?
      @server.run("ufw status").include? "Status: active"
    end
  end
end

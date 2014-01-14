module Conjure
  module Service
    class ForwardedShell
      def initialize(options)
        @shell = options[:shell].prepare(
          :label => "forwarded",
          :setup_commands => [
            "apt-get install -y openssh-server",
            "mkdir -p /var/run/sshd",
            "mkdir -p /root/.ssh; echo '#{options[:public_key]}' > /root/.ssh/authorized_keys",
            "chmod 600 /root/.ssh/authorized_keys"
          ],
        )
      end

      def command(c)
        container = @shell.run "/usr/sbin/sshd -D -e"
        escaped_command = @shell.docker_host.shell_escape c
        ssh_command = "ssh -A -o StrictHostKeyChecking=no -o PasswordAuthentication=no #{container.ip_address} '#{escaped_command}'"
        result = @shell.docker_host.server.run ssh_command
        result.stdout
      end
    end
  end
end

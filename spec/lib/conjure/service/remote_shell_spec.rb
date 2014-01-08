require "conjure/service/remote_shell"
require "conjure/log"
require "mock/net_ssh"

describe Conjure::Service::RemoteShell do
  RemoteShell = Conjure::Service::RemoteShell
  Ssh = Mock::NetSsh

  before do
    Ssh.reset
    RemoteShell.ssh_service = Ssh
    allow(Conjure::Log).to receive(:debug)
  end

  describe "#run" do
    it "opens a session to the correct IP address" do
      RemoteShell.new(:ip_address => "1.2.3.4").run "my command"
      expect(Ssh.last_session.ip_address).to eq("1.2.3.4")
    end

    it "connects with the correct username" do
      RemoteShell.new(:username => "myuser").run "my command"
      expect(Ssh.last_session.username).to eq("myuser")
    end

    it "executes the given command over the session" do
      RemoteShell.new.run "my command"
      expect(Ssh.last_session.command_history).to eq(["my command"])
    end

    it "reuses the same session for subsequent commands" do
      shell = RemoteShell.new
      shell.run "command 1"
      shell.run "command 2"
      expect(Ssh.last_session.command_history).to eq(["command 1", "command 2"])
    end

    it "captures standard output" do
      Ssh.on_loop { send_output "a"; send_error "x"; send_output "b" }
      result = RemoteShell.new.run "my command"
      expect(result.stdout).to eq("ab")
    end

    it "captures standard error" do
      Ssh.on_loop { send_error "x"; send_output "b"; send_error "y" }
      result = RemoteShell.new.run "my command"
      expect(result.stderr).to eq("xy")
    end

    it "captures exit status" do
      Ssh.on_loop { send_exit_status 101 }
      result = RemoteShell.new.run "my command"
      expect(result.status).to eq(101)
    end
  end
end

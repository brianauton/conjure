require "test_helper"
require "mock/net_ssh"

class RemoteShellTest < Test
  RemoteShell = Conjure::Service::RemoteShell
  Ssh = Mock::NetSsh

  def setup
    Ssh.reset
    RemoteShell.ssh_service = Ssh
  end

  test "#run opens a session to the correct IP address" do
    RemoteShell.new(:ip_address => "1.2.3.4").run "my command"
    assert_equal "1.2.3.4", Ssh.last_session.ip_address
  end

  test "#run connects with the correct username" do
    RemoteShell.new(:username => "myuser").run "my command"
    assert_equal "myuser", Ssh.last_session.username
  end

  test "#run executes the given command over the session" do
    RemoteShell.new.run "my command"
    assert_equal ["my command"], Ssh.last_session.command_history
  end

  test "#run reuses the same session for subsequent commands" do
    shell = RemoteShell.new
    shell.run "command 1"
    shell.run "command 2"
    assert_equal ["command 1", "command 2"], Ssh.last_session.command_history
  end

  test "#run captures standard output" do
    Ssh.on_loop { send_output "a"; send_error "x"; send_output "b" }
    result = RemoteShell.new.run "my command"
    assert_equal "ab", result.stdout
  end

  test "#run captures standard error" do
    Ssh.on_loop { send_error "x"; send_output "b"; send_error "y" }
    result = RemoteShell.new.run "my command"
    assert_equal "xy", result.stderr
  end

  test "#run captures exit status" do
    Ssh.on_loop { send_exit_status 101 }
    result = RemoteShell.new.run "my command"
    assert_equal 101, result.status
  end

end

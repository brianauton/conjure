require "conjure"

describe Conjure::Command do
  it "shows usage info when no arguments are given" do
    stdout = capture_stdout { invoke_with_arguments "" }
    expect(stdout).to match("Commands:")
    expect(stdout.lines.count).to be >= 6
  end

  it "notifies on stderr if an unknown command is given" do
    stderr = capture_stderr { invoke_with_arguments "invalid_command" }
    expect(stderr).to include("Could not find command")
  end

  describe "'deploy' command" do
    it "allows specifying a branch to deploy with --branch" do
      invoke_with_arguments "deploy --origin /myrepo.git --branch mybranch --test"
      expect(Conjure::Log.history).to match("Deploying mybranch")
    end

    it "allows specifying a branch to deploy with -b" do
      invoke_with_arguments "deploy --origin /myrepo.git -b mybranch --test"
      expect(Conjure::Log.history).to match("Deploying mybranch")
    end

    it "defaults to deploying master if no branch given" do
      invoke_with_arguments "deploy --origin /myrepo.git --test"
      expect(Conjure::Log.history).to match("Deploying master")
    end
  end

  def invoke_with_arguments(arguments)
    Conjure::Command.start(arguments.split " ")
  end

  def capture_stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = STDOUT
  end

  def capture_stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = STDERR
  end
end

require "conjure"

describe Conjure::Command do
  it "shows usage info when no arguments are given" do
    stdout = capture_stdout { invoke_with_arguments "" }
    expect(stdout).to match("Commands:")
    expect(stdout.lines.count).to be >= 6
  end

  it "notifies on stderr if an unknown command is given" do
    expect do
      invoke_with_arguments "invalid_command"
    end.to raise_error(Thor::UndefinedCommandError)
  end

  describe "'deploy' command" do
    before { disable_deployment }

    it "allows specifying a branch to deploy with --branch" do
      expect_codebase_arguments("/myrepo.git", "mybranch", "production")
      invoke_with_arguments "deploy --origin /myrepo.git --branch mybranch"
      expect(Conjure::Log.history).to match("Deploying mybranch")
    end

    it "allows specifying a branch to deploy with -b" do
      expect_codebase_arguments("/myrepo.git", "mybranch", "production")
      invoke_with_arguments "deploy --origin /myrepo.git -b mybranch"
      expect(Conjure::Log.history).to match("Deploying mybranch")
    end

    it "defaults to deploying master if no branch given" do
      expect_codebase_arguments("/myrepo.git", "master", "production")
      invoke_with_arguments "deploy --origin /myrepo.git"
      expect(Conjure::Log.history).to match("Deploying master")
    end
  end

  describe "'show' command" do
    it "renders an ApplicationView to stdout" do
      allow(Conjure::View::ApplicationView).to receive(:new) { double(:render => "output") }
      output = capture_stdout { invoke_with_arguments "show" }
      expect(output).to eq("output\n")
    end
  end

  def invoke_with_arguments(arguments)
    Conjure::Command.start(arguments.split " ")
  end

  def expect_codebase_arguments(*arguments)
    arguments = [anything] + arguments
    expect(Conjure::Service::RailsCodebase).to receive(:new).with(*arguments) do
      double(:install => nil)
    end
  end

  def capture_stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = STDOUT
  end

  def disable_deployment
    allow_any_instance_of(Conjure::Service::RailsCodebase).to receive(:install)
    allow_any_instance_of(Conjure::Service::RailsServer).to receive(:run)
    allow_any_instance_of(Conjure::Service::CloudServer).to receive(:ip_address)
  end
end

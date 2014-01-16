require "conjure"

describe Conjure::Command do
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
end

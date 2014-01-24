require "conjure/application"
require "tmpdir"

describe Conjure::Application do
  it "determines the origin from a git repo at the provided path" do
    Dir.mktmpdir do |path|
      origin = "git@github.com:myname/myapp.git"
      `cd #{path}; git init .; git remote add origin #{origin}; cat .git/config`
      application = Conjure::Application.new(:path => path)
      expect(application.origin).to eq(origin)
    end
  end

  it "uses the provided origin if applicable" do
    application = Conjure::Application.new(:path => "bogus", :origin => "myorigin")
    expect(application.origin).to eq("myorigin")
  end

  it "determines the application name from the origin" do
    application = Conjure::Application.new(:origin => "git@github.com:myname/myapp.git")
    expect(application.name).to eq("myapp")
  end

  describe "#instances" do
    it "creates a collection of instances scoped to the application" do
      application = Conjure::Application.new
      instances = double
      expect(Conjure::Instance).to receive(:where).with(:application => application) { instances }
      expect(application.instances).to eq(instances)
    end
  end

  describe "#data_sets" do
    it "has none when none have been created" do
      application = Conjure::Application.new
      expect(application.data_sets).to be_empty
    end
  end
end

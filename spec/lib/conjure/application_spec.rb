require "conjure/application"
require "tmpdir"

describe Conjure::Application do
  it "determines the origin_url from a git repo at the provided path" do
    Dir.mktmpdir do |path|
      origin = "git@github.com:myname/myapp.git"
      `cd #{path}; git init .; git remote add origin #{origin}; cat .git/config`
      application = Conjure::Application.new(:path => path)
      expect(application.origin_url).to eq(origin)
    end
  end

  it "uses the provided origin_url if applicable" do
    application = Conjure::Application.new(:path => "bogus", :origin_url => "myorigin")
    expect(application.origin_url).to eq("myorigin")
  end

  it "determines the application name from the origin_url" do
    application = Conjure::Application.new(:origin_url => "git@github.com:myname/myapp.git")
    expect(application.name).to eq("myapp")
  end

  describe "#instances" do
    it "has none when none have been created" do
      application = Conjure::Application.new
      expect(application.instances).to be_empty
    end
  end

  describe "#data_sets" do
    it "has none when none have been created" do
      application = Conjure::Application.new
      expect(application.data_sets).to be_empty
    end
  end
end

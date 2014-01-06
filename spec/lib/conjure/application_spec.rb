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
end

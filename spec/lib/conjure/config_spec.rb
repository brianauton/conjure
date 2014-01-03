require "conjure/config"

describe Conjure::Config do
  it "responds to methods of arbitrary string properties" do
    config = Conjure::Config.new("property1" => "abc", "property2" => "def")
    expect(config.property1).to eq("abc")
    expect(config.property2).to eq("def")
  end
end

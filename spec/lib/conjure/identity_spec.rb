require "conjure/identity"

describe Conjure::Identity do
  it "finds full private key path from config" do
    config = double(:config_path => "a/b", :private_key_file => "c/d")
    identity = Conjure::Identity.new(config)
    expect(identity.private_key_path.to_s).to eq("a/b/c/d")
  end

  it "finds full public key path from config" do
    config = double(:config_path => "a/b", :public_key_file => "x/y")
    identity = Conjure::Identity.new(config)
    expect(identity.public_key_path.to_s).to eq("a/b/x/y")
  end
end

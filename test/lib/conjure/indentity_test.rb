require "test_helper"
require "ostruct"

class IdentityTest < Test
  test "finds full private key path from config" do
    config = OpenStruct.new(:config_path => "a/b", :private_key_file => "c/d")
    identity = Conjure::Identity.new(config)
    assert_equal "a/b/c/d", identity.private_key_path.to_s
  end

  test "finds full public key path from config" do
    config = OpenStruct.new(:config_path => "a/b", :public_key_file => "x/y")
    identity = Conjure::Identity.new(config)
    assert_equal "a/b/x/y", identity.public_key_path.to_s
  end
end

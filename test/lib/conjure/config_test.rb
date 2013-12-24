require "test_helper"

class ConfigTest < Test
  test "responds to methods of arbitrary string properties" do
    config = Conjure::Config.new("property1" => "abc", "property2" => "def")
    assert_equal "abc", config.property1
    assert_equal "def", config.property2
  end
end

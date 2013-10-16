require "test_helper"

class ConjureCommandLineTest < Test
  test "shows usage info when no arguments are given" do
    result = run_local "conjure"
    assert_match "Commands:", result.standard_output
    assert result.standard_output.lines.count >= 6
    assert_equal "", result.standard_error
    assert_equal 0, result.exit_status
  end

  test "shows error when an unknown command is given" do
    result = run_local "conjure invalid_command"
    assert_match "Could not find command", result.standard_error
    assert_equal "", result.standard_output
  end

  require "open3"
  def run_local(text)
    result = Open3.capture3 "ruby -Ilib bin/#{text}"
    Struct.new(:standard_output, :standard_error, :exit_status).new *result
  end
end

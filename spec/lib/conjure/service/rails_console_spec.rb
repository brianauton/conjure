require "conjure/service/rails_console"

describe Conjure::Service::RailsConsole do
  it "yields stdout from running the console on the given shell" do
    shell = double
    expected_command = "cd application_root; bundle exec rails console"
    expect(shell).to receive(:command).with(expected_command, :stream_stdin => true).and_yield("myStdout")
    expect{ |b| Conjure::Service::RailsConsole.new(:shell => shell, &b) }.to yield_with_args("myStdout")
  end
end

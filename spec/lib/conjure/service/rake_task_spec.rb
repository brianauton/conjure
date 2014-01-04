require "conjure/service/rake_task"

describe Conjure::Service::RakeTask do
  it "yields stdout from running the task on the given shell" do
    shell = double
    expected_command = "cd application_root; bundle exec rake myRakeTask myArgument"
    expect(shell).to receive(:command).with(expected_command).and_yield("myStdout")
    task_options = {:task => "myRakeTask myArgument", :shell => shell}
    expect{ |b| Conjure::Service::RakeTask.new(task_options, &b) }.to yield_with_args("myStdout")
  end
end

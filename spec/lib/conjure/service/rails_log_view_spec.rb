require "conjure/service/rails_log_view"

describe Conjure::Service::RailsLogView do
  it "yields stdout from running the task on the given shell" do
    shell = double
    expected_command = "tail application_root/log/production.log"
    expect(shell).to receive(:command).with(expected_command).and_yield("myStdout")
    task_options = {:shell => shell}
    expect{ |b| build_log_view(task_options, &b) }.to yield_with_args("myStdout")
  end

  it "passes the correct argument for number of lines" do
    shell = double
    expected_command = "tail -n 5 application_root/log/production.log"
    expect(shell).to receive(:command).with(expected_command)
    build_log_view(:shell => shell, :lines => 5)
  end

  it "passes the correct argument for tailing" do
    shell = double
    expected_command = "tail -f application_root/log/production.log"
    expect(shell).to receive(:command).with(expected_command)
    build_log_view(:shell => shell, :tail => true)
  end

  it "silently rescues from Interrupt exceptions" do
    shell = double
    expect(shell).to receive(:command).and_raise(Interrupt.new)
    expect{ build_log_view(:shell => shell) }.not_to raise_error
  end

  it "uses the correct log file for the provided rails_env" do
    shell = double
    expected_command = "tail application_root/log/myenv.log"
    expect(shell).to receive(:command).with(expected_command)
    build_log_view(:shell => shell, :rails_env => "myenv")
  end

  def build_log_view(options, &block)
    defaults = {:rails_env => "production"}
    Conjure::Service::RailsLogView.new(defaults.merge(options), &block)
  end
end

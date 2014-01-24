require "conjure/instance"

describe Conjure::Instance do
  describe ".where" do
    it "finds all instances yielded by CloudServer.each_with_name_prefix" do
      allow(Conjure::Service::CloudServer).to receive(:each_with_name_prefix).and_yield(stub_server).and_yield(stub_server)
      expect(where_result_array.length).to eq(2)
    end

    it "constructs each instance with the correct rails environment" do
      server = stub_server(:name => "app-myenv")
      allow(Conjure::Service::CloudServer).to receive(:each_with_name_prefix).and_yield(server)
      expect(where_result_array.first.rails_environment).to eq("myenv")
    end

    it "constructs each instance with the correct ip address" do
      server = stub_server(:ip_address => "5.4.3.2")
      allow(Conjure::Service::CloudServer).to receive(:each_with_name_prefix).and_yield(server)
      expect(where_result_array.first.ip_address).to eq("5.4.3.2")
    end

    def where_result_array
      application = instance_double(Conjure::Application, :name => "app")
      Conjure::Instance.where(:application => application).to_a
    end
  end

  def stub_server(attributes = {})
    defaults = {:name => "app-demo", :ip_address => ""}
    instance_double(Conjure::Service::CloudServer, defaults.merge(attributes))
  end
end

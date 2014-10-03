require "conjure/http_request"

describe Conjure::HttpRequest do
  describe "#data" do
    it "issues a GET request via Net::HTTP" do
      request = double
      http = double
      allow(Net::HTTP::Get).to receive(:new) { request }
      expect(request).to receive(:[]=).with "MyHeader", "MyValue"
      allow(http).to receive(:request).with(request) { double(:body => "get result") }
      allow(Net::HTTP).to receive(:start).with("my.host", 443, :use_ssl => true).and_yield http
      options = {:headers => {"MyHeader" => "MyValue"}}
      expect(Conjure::HttpRequest.new("https://my.host", options).data).to eq "get result"
    end

    it "issues a POST request via Net::HTTP" do
      request = double
      http = double
      allow(Net::HTTP::Post).to receive(:new) { request }
      expect(request).to receive(:[]=).with "MyHeader", "MyValue"
      expect(request).to receive(:body=).with "mydata"
      allow(http).to receive(:request).with(request) { double(:body => "post result") }
      allow(Net::HTTP).to receive(:start).with("my.host", 443, :use_ssl => true).and_yield http
      options = {:headers => {"MyHeader" => "MyValue"}, :data => "mydata", :method => :post}
      expect(Conjure::HttpRequest.new("https://my.host", options).data).to eq "post result"
    end
  end
end

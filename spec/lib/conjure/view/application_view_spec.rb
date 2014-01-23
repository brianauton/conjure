require "conjure"

module Conjure::View
  describe ApplicationView do
    it "shows all instances for the given application" do
      instance1 = double(:rails_environment => "staging", :ip_address => "1.2.3.4")
      instance2 = double(:rails_environment => "development", :ip_address => "5.6.7.8")
      application = double(:instances => [instance1, instance2])
      output = ApplicationView.new(application).render
      expect(output).to include("staging")
      expect(output).to include("1.2.3.4")
      expect(output).to include("development")
      expect(output).to include("5.6.7.8")
    end
  end
end

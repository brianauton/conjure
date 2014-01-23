require "conjure"

module Conjure::View
  describe ApplicationView do
    it "includes intro" do
      view = build_application_view
      expect(view.render).to include("Showing application status")
    end

    it "includes Conjure name and version" do
      stub_const("Conjure::VERSION", "9.8.7")
      view = build_application_view
      expect(view.render).to include("Conjure v9.8.7")
    end

    it "includes basic info about the application" do
      view = build_application_view(:origin => "myorigin")
      expect(view.render).to match(/^Origin[ ]+myorigin/)
    end

    it "shows all instances for the given application" do
      view = build_application_view(:instances => [
        double(:rails_environment => "staging", :ip_address => "1.2.3.4"),
        double(:rails_environment => "development", :ip_address => "5.6.7.8"),
      ])
      expect(view.render).to include("staging")
      expect(view.render).to include("1.2.3.4")
      expect(view.render).to include("development")
      expect(view.render).to include("5.6.7.8")
    end

    def build_application_view(application_attributes = {})
      defaults = {:instances => [], :origin => "none"}
      application = double(defaults.merge application_attributes)
      ApplicationView.new(application)
    end
  end
end

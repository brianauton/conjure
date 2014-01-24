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

    it "indicates if there are no instances" do
      view = build_application_view(:instances => [])
      expect(view.render).to include("(none)")
    end

    it "shows environments for all instances" do
      view = build_application_view(:instances => [
        stub_instance(:rails_environment => "staging"),
        stub_instance(:rails_environment => "development"),
      ])
      expect(view.render).to include("staging")
      expect(view.render).to include("development")
    end

    it "shows ip addresses for all instances" do
      view = build_application_view(:instances => [
        stub_instance(:ip_address => "1.2.3.4"),
        stub_instance(:ip_address => "5.6.7.8"),
      ])
      expect(view.render).to include("1.2.3.4")
      expect(view.render).to include("5.6.7.8")
    end

    it "shows status for all instances" do
      view = build_application_view(:instances => [
        stub_instance(:status => "hyper-archived"),
        stub_instance(:status => "on fire"),
      ])
      expect(view.render).to include("hyper-archived")
      expect(view.render).to include("on fire")
    end

    def build_application_view(attributes = {})
      defaults = {:instances => [], :origin => "none"}
      application = instance_double(Conjure::Application, defaults.merge(attributes))
      ApplicationView.new(application)
    end

    def stub_instance(attributes)
      defaults = {:rails_environment => "", :ip_address => "", :status => ""}
      instance_double(Conjure::Instance, defaults.merge(attributes))
    end
  end
end

require "conjure"

module Conjure::View
  describe ApplicationView do
    let(:application_attributes) { {} }
    let(:application) do
      defaults = {:instances => [], :origin => "none"}
      double(defaults.merge application_attributes)
    end
    let(:rendered_output) { ApplicationView.new(application).render }

    it "includes intro" do
      expect(rendered_output).to include("Showing application status")
    end

    it "includes Conjure name and version" do
      stub_const("Conjure::VERSION", "9.8.7")
      expect(rendered_output).to include("Conjure v9.8.7")
    end

    describe "application info section" do
      let(:application_attributes) { {:origin => "myorigin"} }

      it "should include basic info about the application" do
        expect(rendered_output).to match(/^Origin[ ]+myorigin/)
      end
    end

    describe "view of application's instances" do
      let :application_attributes do
        {:instances => [
          double(:rails_environment => "staging", :ip_address => "1.2.3.4"),
          double(:rails_environment => "development", :ip_address => "5.6.7.8"),
        ]}
      end

      it "shows all instances for the given application" do
        expect(rendered_output).to include("staging")
        expect(rendered_output).to include("1.2.3.4")
        expect(rendered_output).to include("development")
        expect(rendered_output).to include("5.6.7.8")
      end
    end
  end
end

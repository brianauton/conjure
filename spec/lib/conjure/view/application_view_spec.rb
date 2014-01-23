require "conjure"

module Conjure::View
  describe ApplicationView do
    let(:application_attributes) { {} }
    let(:application) { double(application_attributes) }
    let(:rendered_output) { ApplicationView.new(application).render }

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

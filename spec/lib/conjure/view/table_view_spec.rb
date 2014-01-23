require "conjure"

module Conjure
  module View
    describe TableView do
      it "should render a text table of the provided data" do
        data = [
          {:red => 32, :blue => "fifteen"},
          {:red => 47, :green => "xyz"},
          {:blue => nil, :green => "abc"},
        ]
        view = TableView.new(data)
        expect(view.render).to eq("red  blue     green\n32   fifteen       \n47            xyz  \n              abc  ")
      end
    end
  end
end

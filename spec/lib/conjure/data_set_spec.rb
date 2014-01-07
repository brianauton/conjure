require "conjure/data_set"

describe Conjure::DataSet do
  describe ".find" do
    it "finds no data sets when none have been created" do
      expect(Conjure::DataSet.find).to be_empty
    end
  end
end

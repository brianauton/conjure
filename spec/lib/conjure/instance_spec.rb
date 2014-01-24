require "conjure/instance"

describe Conjure::Instance do
  describe ".find" do
    it "finds no instances when none have been created" do
      expect(Conjure::Instance.where.to_a).to eq([])
    end
  end
end

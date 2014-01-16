require "conjure/log"

describe Conjure::Log do
  describe ".history" do
    it "should show collected output when capture mode is activated" do
      Conjure::Log.capture = true
      Conjure::Log.clear
      Conjure::Log.info("Line 1")
      Conjure::Log.info("Line 2")
      expect(Conjure::Log.history).to eq("Line 1\nLine 2\n")
    end
  end

  describe ".clear" do
    it "should clear the stored history" do
      Conjure::Log.capture = true
      Conjure::Log.info("Line 1")
      Conjure::Log.clear
      Conjure::Log.info("Line 2")
      expect(Conjure::Log.history).to eq("Line 2\n")
    end
  end
end

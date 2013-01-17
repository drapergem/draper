shared_examples_for "view helpers" do |subject|
  describe "#helpers" do
    it "returns the class's helpers" do
      expect(subject.helpers).to be subject.class.helpers
    end

    it "is aliased to #h" do
      expect(subject.h).to be subject.helpers
    end
  end

  describe "#localize" do
    it "delegates to #helpers" do
      subject.helpers.should_receive(:localize).with(:an_object, some: "parameter")
      subject.localize(:an_object, some: "parameter")
    end

    it "is aliased to #l" do
      subject.helpers.should_receive(:localize).with(:an_object, some: "parameter")
      subject.l(:an_object, some: "parameter")
    end
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      expect(subject.class.helpers).to be_a Draper::HelperProxy
    end

    it "memoizes" do
      helpers = subject.class.helpers

      expect(subject.class.helpers).to be helpers
    end

    it "is aliased to .h" do
      expect(subject.class.h).to be subject.class.helpers
    end
  end
end

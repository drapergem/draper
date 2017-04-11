shared_examples_for "view helpers" do |subject|
  describe "#helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      expect(subject.helpers).to be :current_view_context
    end

    it "is aliased to #h" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      expect(subject.h).to be :current_view_context
    end
  end

  describe "#localize" do
    it "delegates to #helpers" do
      allow(subject).to receive(:helpers).and_return(double)
      expect(subject.helpers).to receive(:localize).with(:an_object, some: "parameter")
      subject.localize(:an_object, some: "parameter")
    end

    it "is aliased to #l" do
      allow(subject).to receive_messages helpers: double
      expect(subject.helpers).to receive(:localize).with(:an_object, some: "parameter")
      subject.l(:an_object, some: "parameter")
    end
  end

  describe ".helpers" do
    it "returns the current view context" do
      allow(Draper::ViewContext).to receive_messages current: :current_view_context
      expect(subject.class.helpers).to be :current_view_context
    end

    it "is aliased to .h" do
      allow(Draper::ViewContext).to receive(:current).and_return(:current_view_context)
      expect(subject.class.h).to be :current_view_context
    end
  end
end
